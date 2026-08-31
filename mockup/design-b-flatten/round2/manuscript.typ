#import "../../../lib.typ": *

// This file stands in for the output of an (unimplemented) "flatten"
// tool: round 1's accepted wording only, baked in as plain prose --- no
// passage()/add()/del()/rep() left anywhere, exactly as if round 1 had
// never used palimpsest at all. A real Design B implementation would
// generate this automatically from round 1's manuscript.typ + accepted
// diffs; here it was produced by hand, reading round 1's own
// manuscript.pdf (clean) and copying its text verbatim.
//
// Round 2's own marking starts completely fresh below --- new anchors,
// reusing `<r1-1>` with no collision or ambiguity, because this is a
// wholly separate compile from round 1's.

= Introduction

#passage(<r1-1>)[The treatment has a clinically meaningful effect on survival#add[, with the largest benefit observed in the first 24 hours].]

A truncation-based sensitivity analysis has been added, as suggested by the reviewer.
