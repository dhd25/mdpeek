#!/bin/bash
# Generates a ~10MB markdown file for size/truncation testing.
set -e
OUT="$(dirname "$0")/large.md"
{
  echo "# Large file"
  for i in $(seq 1 50000); do
    echo "Paragraph $i — lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
  done
} > "$OUT"
wc -c "$OUT"
