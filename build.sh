#!/usr/bin/env bash
# ============================================================
# Build script for the SugarCube Linter Testbed.
# Compiles all .twee/.js/.css files under src/ into a single
# HTML file using Tweego and the SugarCube-2 story format.
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"
DIST_DIR="$SCRIPT_DIR/dist"
OUTPUT="$DIST_DIR/story.html"

mkdir -p "$DIST_DIR"

# Default format is sugarcube-2 already, but we pass it explicitly for clarity.
# -t   test mode (Twine 2-style formats only)
# -l   log passage/word counts
# -o   output file
tweego \
  -f sugarcube-2 \
  -t \
  -l \
  -o "$OUTPUT" \
  "$SRC_DIR"

echo ""
echo "✓ Built: $OUTPUT"
echo "  Open it in a browser to play / inspect."
