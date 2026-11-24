# Verify a change and show it in the pull request

Every pull request shows the change working ([standards.md](../standards.md), "Show it working").
Do this after the code is done and before you open the pull request, then again after a change that
alters what people see. Each step ends on its completion criterion.

1. **Run it the way it ships.** Build for production and start it locally, or use the pull
   request's preview deployment. Never a mockup, a design file or a dev-only page. Done when every
   page or screen you changed opens in the browser.
2. **Capture.** For pages that only need opening and scrolling:

   ```sh
   node .agents/shared/scripts/pr-evidence/capture.mjs --base http://localhost:<port> --out <dir> <path> <path> ...
   ```

   List each changed page once per language, for example `/about/ /id/about/`. The script takes a
   full-page screenshot of each at phone and desktop size and records one demo video that walks
   through them. In a Claude cloud session, put `CHROME_PATH=/opt/pw-browsers/chromium` in front and
   use the scratchpad as `<dir>`. It exits 1 when a page answers with an error, logs a console error
   or fails a request.

   A flow with clicks, typing or sign-in needs its own Playwright script, or the repository's own
   capture command if its `AGENTS.md` names one. Record the video with Playwright's `recordVideo` and
   convert it with `ffmpeg` to `.mp4`, plus a short `.gif` of the same name as its preview.

   A change with nothing to see (CI, configuration, a library, a backend rule) needs no capture: keep
   the commands you ran and their output. Done when you have a screenshot of each changed screen in
   each language and size, and a video of each changed flow from its start to its result.
3. **Look.** Open every screenshot and watch the video (an agent reads the images and a few frames:
   `ffmpeg -ss <second> -i demo.mp4 -frames:v 1 frame.png`). Check that the change is there and
   works, and look for empty sections, clipped or overlapping text, a missing translation, a broken
   image, and the other language or size breaking. Fix what you find and capture again. Done when
   the evidence shows the change working and nothing broken.
4. **Publish.** On the pull request's branch:

   ```sh
   sh .agents/shared/scripts/pr-evidence/publish.sh <dir>
   git push
   ```

   It adds the files in one commit and takes them out in the next, so they never reach `main`. The
   "PR evidence" check finds that commit, counts its files as the screenshots and video, and shows
   them in a comment on the pull request. Don't paste images into the description yourself: an
   agent's GitHub tool strips them. A person working in the browser can drag files into the
   description instead. Done when the push succeeded and the comment shows every file.
5. **Write the Verification section.** Under `## Verification` in the description, say what each
   screen and video shows and what you checked. For a change with nothing to see, write
   `No visible surface:` with the reason, then the commands and their output in a code block. Done
   when the "PR evidence" check passes.

The "PR evidence" check (in Ascentwright-Capital/.github) fails a pull request without a
Verification section, without a screenshot and a video, or that claims "No visible surface" while it
changes files people see.
