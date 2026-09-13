#!/bin/bash
echo "🚀 Compiling Typst Palimpsest..."
cd "$(dirname "$0")"

# Root is the parent "typst templates" directory, not this one: this
# package now imports ../typst-contexture/lib.typ (a sibling package,
# unpublished for now) directly, so the sandbox has to cover both
# directories — see CLAUDE.md, "Migration vers contexture". Every
# root-relative path used by the package (letter-bibliography, ...) is
# written as "/typst-palimpsest/..." accordingly, not bare "/...".

# Docs
for file in docs/*.typ; do
    [ -f "$file" ] && typst compile --root .. "$file"
done

# Examples (single-file, e.g. examples/foo.typ)
for file in examples/*.typ; do
    [ -f "$file" ] && typst compile --root .. "$file"
done

# Examples requiring the bundle export (a subdirectory with its own
# main.typ) — both the default clean compile and the tracked one
# (§9.1: two separate compiles, never one bundle with both), same as
# the equivalent tests/bundle-*/ loop further down. Previously missing
# the tracked pass entirely, so manuscript-tracked.pdf/response-tracked.pdf
# under examples/*/main/ were never refreshed by this script (caught
# because they kept a stale mtime across a src/ change that visibly
# affects tracked-mode rendering — see CLAUDE.md).
for dir in examples/*/; do
    file="${dir}main.typ"
    if [ -f "$file" ]; then
        typst compile --features bundle --format bundle --root .. "$file"
        typst compile --features bundle --format bundle --root .. --input variant=tracked "$file"
    fi
done

# Examples needing no bundle at all (a subdirectory with its own
# manuscript.typ but no main.typ — the "no letter document" workflow,
# e.g. examples/coauthors-simple/): both clean and tracked, same as the
# two bundle compiles above, just without --features/--format. Explicit,
# distinct output paths for both — omitting them would make both calls
# infer the same "manuscript.pdf" output and the tracked one would
# silently overwrite the clean one (see CLAUDE.md, the identical bug
# found with change-list's own two-compile verification).
for dir in examples/*/; do
    file="${dir}manuscript.typ"
    mainfile="${dir}main.typ"
    if [ -f "$file" ] && [ ! -f "$mainfile" ]; then
        typst compile --root .. "$file" "${dir}manuscript.pdf"
        typst compile --root .. --input variant=tracked "$file" "${dir}manuscript-tracked.pdf"
    fi
done

# Tests (single-document, no bundle)
for file in tests/*.typ; do
    case "$file" in
        tests/bundle-*.typ) continue ;;
    esac
    [ -f "$file" ] && typst compile --root .. "$file"
done

# Tests requiring the bundle export (single-file, e.g. tests/bundle-foo.typ)
for file in tests/bundle-*.typ; do
    [ -f "$file" ] && typst compile --features bundle --format bundle --root .. "$file"
done

# Tests requiring the bundle export (a subdirectory with its own main.typ,
# e.g. tests/bundle-pilot/main.typ, tests/bundle-ieee/main.typ) — both
# the default clean compile and the tracked one (§9.1: two separate
# compiles, never one bundle with both).
for dir in tests/bundle-*/; do
    file="${dir}main.typ"
    if [ -f "$file" ]; then
        typst compile --features bundle --format bundle --root .. "$file"
        typst compile --features bundle --format bundle --root .. --input variant=tracked "$file"
    fi
done
