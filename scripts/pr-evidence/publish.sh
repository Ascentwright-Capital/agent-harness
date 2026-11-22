#!/bin/sh
# Puts pull request evidence (screenshots and videos) on GitHub without the files reaching main, and
# prints the Markdown for the pull request's "Verification" section.
#
#   sh .agents/shared/scripts/pr-evidence/publish.sh <evidence-dir>
#   git push
#
# Adds two commits to the current branch: the first adds the files under .pr-evidence/<time>/, the
# second removes them again. The Markdown links to the first commit, so the pictures stay viewable
# after the squash merge, and main never gets the files. Your working tree and index are not touched.
# The steps are in workflows/verify.md.
set -eu

die() { echo "publish: $1" >&2; exit 1; }

src=${1:-}
[ -n "$src" ] && [ -d "$src" ] || die "usage: publish.sh <evidence-dir>"
src=${src%/}
git rev-parse --git-dir >/dev/null 2>&1 || die "run this inside the repository"
branch=$(git symbolic-ref --short -q HEAD) || die "check out the pull request's branch first"
case "$branch" in main | master) die "you are on $branch; evidence goes on the pull request's branch" ;; esac

# owner/repo of origin, for the links. PR_EVIDENCE_REPO overrides it.
repo=${PR_EVIDENCE_REPO:-$(git remote get-url origin | sed -E 's#\.git$##; s#/$##; s#^.*[/:]([^/:]+/[^/:]+)$#\1#')}
printf '%s' "$repo" | grep -Eq '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$' || die "cannot read owner/repo from origin; set PR_EVIDENCE_REPO"

# Paths relative to the evidence directory, in name order.
files=$(cd "$src" && find . -type f | sed 's#^\./##' | grep -Ei '\.(png|jpe?g|webp|gif|mp4|webm|mov)$' | LC_ALL=C sort) || true
[ -n "$files" ] || die "no screenshots or videos in $src"
# The commit titles carry the issue: PR_EVIDENCE_ISSUE (AP-12), else read from a
# <type>/ap-<number>-<slug> branch.
issue=${PR_EVIDENCE_ISSUE:-$(printf '%s' "$branch" | sed -nE 's#^[a-z]+/ap-([0-9]+)-.*#AP-\1#p')}

max=$((25 * 1024 * 1024))
dest=.pr-evidence/$(date -u +%Y%m%d-%H%M%S)
head=$(git rev-parse HEAD)
index=$(mktemp)
trap 'rm -f "$index"' EXIT

# Build the evidence commit in a private index, so nothing staged or unstaged is swept into it.
GIT_INDEX_FILE=$index git read-tree "$head"
printf '%s\n' "$files" | while IFS= read -r rel; do
  printf '%s' "$rel" | grep -Eq '^[A-Za-z0-9._/-]+\.(png|jpe?g|webp|gif|mp4|webm|mov)$' ||
    die "rename $rel: letters, digits, dots, dashes and slashes only, and a lower-case extension"
  [ "$(wc -c <"$src/$rel" | tr -d ' ')" -le "$max" ] || die "$rel is over 25 MB; shorten or compress it"
  GIT_INDEX_FILE=$index git update-index --add --cacheinfo "100644,$(git hash-object -w -- "$src/$rel"),$dest/$rel"
done
added=$(git commit-tree "$(GIT_INDEX_FILE=$index git write-tree)" -p "$head" -m "[Docs] Add pull request evidence${issue:+ ($issue)}")
removed=$(git commit-tree "$head^{tree}" -p "$added" -m "[Docs] Take the pull request evidence out of the tree${issue:+ ($issue)}")
git update-ref -m "pr-evidence: publish $dest" "refs/heads/$branch" "$removed" "$head"

url() { printf 'https://github.com/%s/blob/%s/%s/%s?raw=true' "$repo" "$added" "$dest" "$1"; }

echo "Added $(printf '%s\n' "$files" | wc -l | tr -d ' ') file(s) in commit $added and took them out again in $removed."
echo "Push the branch, then paste this under \"## Verification\" and say what you checked:"
echo
has() { printf '%s\n' "$files" | grep -Fxq "$1"; }
printf '%s\n' "$files" | while IFS= read -r rel; do
  base=${rel%.*}
  video=
  for ext in mp4 webm mov; do has "$base.$ext" && { video=$base.$ext; break; }; done
  case "$rel" in
    *.gif)
      # A GIF next to a video of the same name is its preview: show it, and link it to the video.
      if [ -n "$video" ]; then
        printf '[![Demo video: %s](%s)](%s)\n\n[Demo video (%s)](%s)\n\n' "$base" "$(url "$rel")" "$(url "$video")" "${video##*.}" "$(url "$video")"
      else
        printf '![%s](%s)\n\n' "$rel" "$(url "$rel")"
      fi
      ;;
    *.mp4 | *.webm | *.mov) has "$base.gif" || printf '[Video: %s](%s)\n\n' "$rel" "$(url "$rel")" ;;
    # Full-page screenshots are tall: show them narrow, a page's phone and desktop side by side.
    # GitHub opens the full size on click. A desktop shot with a phone twin is printed with it.
    *-phone.*)
      desktop=${base%-phone}-desktop.${rel##*.}
      printf '**%s**\n\n<img src="%s" alt="%s" width="240">' "${base%-phone}" "$(url "$rel")" "$rel"
      has "$desktop" && printf ' <img src="%s" alt="%s" width="560">' "$(url "$desktop")" "$desktop"
      printf '\n\n'
      ;;
    *-desktop.*) has "${base%-desktop}-phone.${rel##*.}" || printf '**%s**\n\n<img src="%s" alt="%s" width="560">\n\n' "$base" "$(url "$rel")" "$rel" ;;
    *) printf '**%s**\n\n<img src="%s" alt="%s" width="560">\n\n' "$base" "$(url "$rel")" "$rel" ;;
  esac
done
