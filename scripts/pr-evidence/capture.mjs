#!/usr/bin/env node
// Captures the evidence a pull request shows: a full-page screenshot of each page at phone and
// desktop size, and one demo video that visits the pages in order and scrolls through each.
// The rule is in standards.md, "Show it working"; the steps are in workflows/verify.md.
//
//   node .agents/shared/scripts/pr-evidence/capture.mjs --base http://localhost:4173 [--out <dir>] / /id/ ...
//
// Each path is one page: list every language as its own path. The pages are read from a running
// build; this script starts nothing. Writes <out>/screens/*.jpg and <out>/demo.mp4 with a
// <out>/demo.gif preview (or <out>/demo.webm without ffmpeg). Exits 1 when a page answers with an
// error, logs a console error, or fails a request: fix that before you publish the evidence.
// A flow that needs clicks and typing belongs in a Playwright script of its own; publish its output.
//
// Uses the project's Playwright if it has one, else the one on NODE_PATH. CHROME_PATH sets the
// browser binary, as in a Claude cloud session: CHROME_PATH=/opt/pw-browsers/chromium.

import { execFileSync } from "node:child_process";
import { mkdirSync, mkdtempSync, renameSync, rmSync } from "node:fs";
import { createRequire } from "node:module";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { parseArgs } from "node:util";

const usage = "usage: capture.mjs --base <url> [--out <dir>] <path> [<path> ...]";
const { values, positionals } = parseArgs({
  options: { base: { type: "string" }, out: { type: "string" }, help: { type: "boolean", short: "h" } },
  allowPositionals: true,
});
if (values.help) {
  console.log(usage);
  process.exit(0);
}
if (!values.base || positionals.length === 0) {
  console.error(usage);
  process.exit(2);
}

// Phone at double density so its text stays sharp; desktop at single density to keep files small.
const sizes = {
  phone: { viewport: { width: 390, height: 844 }, deviceScaleFactor: 2, isMobile: true, hasTouch: true },
  desktop: { viewport: { width: 1440, height: 900 }, deviceScaleFactor: 1 },
};
const videoSize = { width: 1280, height: 800 };
const out = resolve(values.out ?? mkdtempSync(join(tmpdir(), "pr-evidence-")));
const screens = join(out, "screens");
mkdirSync(screens, { recursive: true });

function loadPlaywright() {
  for (const from of [join(process.cwd(), "noop.js"), import.meta.filename]) {
    try {
      return createRequire(from)("playwright");
    } catch {}
  }
  console.error("capture: Playwright not found. Install it in the project, or run where it is on NODE_PATH.");
  process.exit(2);
}

// "/" -> "home", "/id/adiruang/" -> "id-adiruang", numbered so the files sort in the order given.
const name = (path, i) =>
  `${String(i + 1).padStart(2, "0")}-${path.replace(/[?#].*$/, "").replace(/[^A-Za-z0-9]+/g, "-").replace(/^-|-$/g, "") || "home"}`;

const problems = [];
function watch(page, path) {
  page.on("console", (m) => m.type() === "error" && problems.push(`${path}: console error: ${m.text()}`));
  page.on("pageerror", (e) => problems.push(`${path}: page error: ${e.message}`));
  // ERR_ABORTED is a request the page itself cancelled, such as a prefetch cut off by navigation.
  page.on("requestfailed", (r) => {
    const error = r.failure()?.errorText ?? "";
    if (!error.includes("ERR_ABORTED")) problems.push(`${path}: request failed: ${r.url()} (${error})`);
  });
}

async function open(page, path) {
  const url = new URL(path, values.base).href;
  const response = await page.goto(url, { waitUntil: "load" });
  if (!response || response.status() >= 400) problems.push(`${path}: answered ${response?.status() ?? "nothing"}`);
  await page.waitForLoadState("networkidle", { timeout: 5000 }).catch(() => {});
  // Fonts and lazy images: let them land before the picture.
  await page.evaluate(() => document.fonts?.ready);
  await page.waitForTimeout(400);
}

// Scroll to the bottom and back, so sections that appear or load on scroll are in the picture.
// "instant": a page with scroll-behavior: smooth would otherwise lag far behind each step.
async function reveal(page) {
  await page.evaluate(async () => {
    const pause = () => new Promise((r) => setTimeout(r, 150));
    for (let y = 0; y < document.documentElement.scrollHeight; y += window.innerHeight / 2) {
      window.scrollTo({ top: y, behavior: "instant" });
      await pause();
    }
    window.scrollTo({ top: 0, behavior: "instant" });
    await pause();
  });
  // Revealed sections fade in; let the fade finish.
  await page.waitForTimeout(1000);
}

const { chromium } = loadPlaywright();
const browser = await chromium.launch(process.env.CHROME_PATH ? { executablePath: process.env.CHROME_PATH } : {});
try {
  for (const [size, options] of Object.entries(sizes)) {
    const context = await browser.newContext(options);
    for (const [i, path] of positionals.entries()) {
      const page = await context.newPage();
      if (size === "desktop") watch(page, path);
      await open(page, path);
      await reveal(page);
      // JPEG: a full page of photos is several megabytes as PNG, a quarter of that as JPEG.
      await page.screenshot({ path: join(screens, `${name(path, i)}-${size}.jpg`), fullPage: true, type: "jpeg", quality: 80 });
      await page.close();
    }
    await context.close();
  }

  // The demo: one tab, every page in order, scrolled top to bottom at reading pace.
  const raw = join(out, "raw-video");
  const context = await browser.newContext({ viewport: videoSize, recordVideo: { dir: raw, size: videoSize } });
  const page = await context.newPage();
  for (const path of positionals) {
    await open(page, path);
    await page.waitForTimeout(800);
    for (let step = 0; step < 16; step++) {
      const atEnd = await page.evaluate(() => {
        window.scrollBy({ top: window.innerHeight * 0.85, behavior: "smooth" });
        return window.scrollY + window.innerHeight >= document.documentElement.scrollHeight - 2;
      });
      await page.waitForTimeout(700);
      if (atEnd) break;
    }
    await page.waitForTimeout(600);
  }
  const video = page.video();
  await context.close();
  const webm = join(out, "demo.webm");
  renameSync(await video.path(), webm);
  rmSync(raw, { recursive: true, force: true });

  try {
    const ffmpeg = (...args) => execFileSync("ffmpeg", ["-y", "-loglevel", "error", "-i", webm, ...args], { stdio: "inherit" });
    ffmpeg("-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "28", "-preset", "veryfast", "-movflags", "+faststart", "-an", join(out, "demo.mp4"));
    // The GIF is the preview GitHub plays inline: the first 20 seconds, small enough to load fast.
    const palette = "palettegen=max_colors=48:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle";
    ffmpeg("-t", "20", "-vf", `fps=4,scale=560:-1:flags=lanczos,split[a][b];[a]${palette}`, join(out, "demo.gif"));
    rmSync(webm);
  } catch {
    console.warn("capture: ffmpeg failed or is missing; kept demo.webm. GitHub cannot preview it inline.");
  }
} finally {
  await browser.close();
}

console.log(`Evidence in ${out}`);
const found = [...new Set(problems)];
if (found.length > 0) {
  console.error(`\n${found.length} problem(s) while loading the pages. Fix them before you publish:`);
  for (const p of found) console.error(`  ${p}`);
  process.exit(1);
}
