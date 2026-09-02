#!/bin/bash
# Regenerates every pre-rendered PNG the manual embeds, then recompiles
# the manual file(s) that use them — the two-pipeline approach: real
# example .typ files under docs/manual-snippets/ are compiled for
# real (clean and tracked, genuinely separate compiles), and the manual
# itself (docs/manual*.typ) just does read()/image() on the results,
# no package import, no eval().
#
# Snippet convention, so this script can stay generic instead of
# special-casing each file:
# - A snippet with no `#document(...)`/`revisions(...)` call is a
#   "plain" file (passage/add/del/... directly, no bundle) -> compiled
#   straight to <name>/result-clean.png and <name>/result-tracked.png.
# - A snippet with `#document("foo.ext", ...)` call(s), or one using
#   the real `revisions()`/`revisions.with(...)` pilot (which calls
#   `document(...)` internally, so it needs the same bundle flags even
#   though the snippet's own source never spells out `#document(`), is
#   a bundle -> each named output gets a `-clean`/`-tracked` suffix:
#   <name>/foo-clean.ext, <name>/foo-tracked.ext. (A snippet only
#   interesting in one mode still produces both; the manual just
#   doesn't have to embed the uninteresting one.)
# - PNG export only supports a single-page document (Typst enforces
#   this) — a snippet that genuinely needs more than one manuscript
#   page (see pinpoint-two-pages.typ) must name that document
#   "....pdf" instead of "....png" to compile at all. This script
#   always rasterizes such a PDF into PNGs afterward (one file per
#   page, `-1`, `-2`, ...) so the manual only ever embeds PNGs — the
#   `.pdf` vs `.png` choice in a snippet's own source is purely a
#   single-page-vs-multi-page technicality, invisible once regenerated.
set -e
cd "$(dirname "$0")/../.."

rasterize() {
    # $1: source file (any format typst can produce); $2: destination
    # stem (no extension). A single-page source becomes "$2.png"; a
    # multi-page PDF becomes "$2-1.png", "$2-2.png", etc.
    local src="$1" stem="$2"
    case "$src" in
        *.pdf)
            local pages
            pages="$(pdfinfo "$src" | awk '/^Pages:/ {print $2}')"
            if [ "$pages" = "1" ]; then
                pdftoppm -png -r 300 -f 1 -l 1 "$src" "$stem"
                mv "${stem}-1.png" "${stem}.png" 2>/dev/null || mv "${stem}-01.png" "${stem}.png"
            else
                pdftoppm -png -r 300 "$src" "$stem"
                # pdftoppm zero-pads (e.g. "-01"); strip the padding so
                # the manual can reference "-1", "-2", ... predictably.
                for f in "$stem"-0*.png; do
                    [ -f "$f" ] || continue
                    mv "$f" "$(echo "$f" | sed -E 's/-0+([0-9]+)\.png$/-\1.png/')"
                done
            fi
            ;;
        *)
            cp "$src" "$stem.${src##*.}"
            ;;
    esac
}

for src in docs/manual-snippets/*.typ; do
    [ -f "$src" ] || continue
    name="$(basename "$src" .typ)"
    outdir="docs/manual-snippets/$name"
    rm -rf "$outdir"
    mkdir -p "$outdir"

    if grep -qE '#document\(|revisions\.with\(|show: *revisions\b' "$src"; then
        tmp_clean="$(mktemp -d)"
        tmp_tracked="$(mktemp -d)"
        typst compile --features bundle --format bundle --ppi 300 --root . "$src" "$tmp_clean"
        typst compile --features bundle --format bundle --ppi 300 --root . --input mode=tracked "$src" "$tmp_tracked"
        for f in "$tmp_clean"/*; do
            base="$(basename "$f")"
            stem="${base%.*}"
            # revisions() itself never names a clean-mode output "-clean"
            # (only its tracked one is self-named "manuscript-tracked"),
            # so no collision to guard here -- always append.
            rasterize "$f" "$outdir/${stem}-clean"
        done
        for f in "$tmp_tracked"/*; do
            base="$(basename "$f")"
            stem="${base%.*}"
            # revisions() names its own tracked output "manuscript-tracked"
            # -- don't double up into "manuscript-tracked-tracked".
            case "$stem" in
                *-tracked) rasterize "$f" "$outdir/${stem}" ;;
                *) rasterize "$f" "$outdir/${stem}-tracked" ;;
            esac
        done
        rm -rf "$tmp_clean" "$tmp_tracked"
    else
        typst compile --ppi 300 --root . "$src" "$outdir/result-clean.png"
        typst compile --ppi 300 --root . --input mode=tracked "$src" "$outdir/result-tracked.png"
    fi
    echo "  $name -> $outdir/"
done

echo "Snippets regenerated. Compiling manual(s)..."
for manual in docs/manual*.typ; do
    [ -f "$manual" ] || continue
    typst compile --root . "$manual"
    echo "  $manual"
done

echo "Done."
