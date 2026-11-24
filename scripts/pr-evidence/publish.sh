#!/bin/sh
# Puts pull request evidence (screenshots and videos) on GitHub without the files reaching main.
#
#   sh .agents/shared/scripts/pr-evidence/publish.sh <evidence-dir>
#   git push
#
# Adds two commits to the current branch: the first adds the files under .pr-evidence/<time>/, the
# second removes them again, so main never gets them. The PR evidence check (Ascentwright-Capital/.github)
# finds the first commit, counts its files as the screenshots and video, and shows them in a comment
# on the pull request. Your working tree and index are not touched. The steps are in workflows/verify.md.
set -eu

die() { echo "publish: $1" >&2; exit 1; }

src=${1:-}
[ -n "$src" ] && [ -d "$src" ] || die "usage: publish.sh <evidence-dir>"
src=${src%/}
git rev-parse --git-dir >/dev/null 2>&1 || die "run this inside the repository"
branch=$(git symbolic-ref --short -q HEAD) || die "check out the pull request's branch first"
case "$branch" in main | master) die "you are on $branch; evidence goes on the pull request's branch" ;; esac

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

echo "Added $(printf '%s\n' "$files" | wc -l | tr -d ' ') file(s) under $dest in commit $added, and took them out again in $removed."
echo "Push the branch. The PR evidence check shows the files in a comment on the pull request."
echo "Under \"## Verification\" in the description, say what each screen and video shows and what you checked."
