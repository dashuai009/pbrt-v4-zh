#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .tools/bin .tools/downloads
case "$(uname -s)-$(uname -m)" in
  Darwin-arm64) target=aarch64-apple-darwin ;;
  Linux-x86_64) target=x86_64-unknown-linux-musl ;;
  *) echo 'Unsupported platform; install Typst 0.13.1 and shiroa 0.3.0 explicitly.' >&2; exit 1 ;;
esac
if ! test -x .tools/bin/typst; then
  curl --fail --location --retry 3 "https://github.com/typst/typst/releases/download/v0.13.1/typst-${target}.tar.xz" -o .tools/downloads/typst.tar.xz
  tar -xf .tools/downloads/typst.tar.xz -C .tools/downloads
  cp ".tools/downloads/typst-${target}/typst" .tools/bin/typst
fi
if ! test -x .tools/bin/shiroa; then
  archive="shiroa-${target}.tar.gz"
  curl --fail --location --retry 3 "https://github.com/Myriad-Dreamin/shiroa/releases/download/v0.3.0/${archive}" -o ".tools/downloads/${archive}"
  curl --fail --location --retry 3 "https://github.com/Myriad-Dreamin/shiroa/releases/download/v0.3.0/${archive}.sha256" -o ".tools/downloads/${archive}.sha256"
  (cd .tools/downloads && shasum -a 256 -c "${archive}.sha256")
  tar -xzf ".tools/downloads/${archive}" -C .tools/downloads
  cp ".tools/downloads/shiroa-${target}/shiroa" .tools/bin/shiroa
fi
case "$(.tools/bin/typst --version)" in "typst 0.13.1 "*) ;; *) exit 1 ;; esac
case "$(.tools/bin/shiroa --version)" in "shiroa version 0.3.0"*) ;; *) exit 1 ;; esac
