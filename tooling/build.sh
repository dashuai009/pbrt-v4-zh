#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export PATH="$PWD/.tools/bin:$PATH"
export PAGES_BASE_PATH="${PAGES_BASE_PATH:-/pbrt-v4-zh/}"
mkdir -p output
node tooling/build-snapshot.mjs start
node --test tooling/*.test.mjs
node tooling/original-citations.mjs
node tooling/citation-map.mjs
node tooling/content-check.mjs
node tooling/source-numbers.mjs
node tooling/prepare-link-labels.mjs
for lang in zh en zh-en; do
  if test "$lang" = zh-en; then
    typst compile main.typ "output/pbrt-v4-${lang}.pdf" --font-path fonts
  else
    typst compile main.typ "output/pbrt-v4-${lang}.pdf" --font-path fonts --input "LANG_OUT=$lang"
  fi
done
for lang in zh en; do
  typst query tooling/export-reader-data.typ '<reader-export>' --field value --one --root . --font-path fonts --input "LANG_OUT=$lang" > "output/reader-${lang}.json.tmp"
  mv "output/reader-${lang}.json.tmp" "output/reader-${lang}.json"
  node tooling/split-reader-export.mjs "$lang"
done
node tooling/web-entries.mjs
node tooling/source-links.mjs
node tooling/build-snapshot.mjs generated
shiroa build --mode static-html --font-path fonts --dest-dir output/site --path-to-root "$PAGES_BASE_PATH"
node tooling/check-rendered-content.mjs output/site
node tooling/compact-html.mjs output/site
node tooling/search-index.mjs output/site
node tooling/finalize-site.mjs output/site
node tooling/check-links.mjs output/site

node tooling/build-snapshot.mjs end
