#import "../../lib.typ": *

We thank both reviewers for their careful reading of the manuscript. Below
we address each comment in turn, with the corresponding change in the
manuscript cited by page number.

#reviewer(1)[

  #exchange(<r1-1>)[
    Please specify which propensity score methods were actually used —
    "propensity score methods" alone is too vague.
  ][
    We have specified that we used inverse probability weighting and
    matching. #pinpoint(<r1-1>)
  ]

  #exchange(<r1-11>)[
    A single comment (illustrative, for testing) that required a change
    in two separate sections — the introduction and the conclusion.
  ][
    Addressed in both locations: #pinpoint(<r1-11>).

    Shown as two separate excerpts, one per location:

    #pinpoint(<r1-11>, excerpt: true)
  ]

  #exchange(<r1-2>)[
    How exactly were confounders selected? "Prior clinical knowledge"
    is not a reproducible criterion.
  ][
    We now describe the disjunctive cause criterion, cited in the
    manuscript, as our primary selection method, with clinical
    knowledge used only as a secondary check.

    #pinpoint(<r1-2>, excerpt: true, mode: "tracked")
  ]

  #exchange(<r1-3>)[
    Which target trial emulation framework was followed?
  ][
    We now cite the cloning, censoring, and weighting approach,
    referenced in the manuscript, explicitly. #pinpoint(<r1-3>)
  ]

  #exchange(<r1-4>)[
    Please clarify the censoring events used to define follow-up time.
  ][
    We have kept the original wording here, which we believe already
    answers this point; see the highlighted passage.

    #pinpoint(<r1-4>, excerpt: true)
  ]

  #exchange(<r1-5>)[
    The propensity score model as written does not condition on time
    of entry, which matters for a target trial emulation with staggered
    entry.
  ][
    We agree and have corrected the propensity score definition to
    condition explicitly on $t_0$, and we now also use restricted
    cubic splines for continuous covariates.

    #pinpoint(<r1-5>, excerpt: true)
  ]

  #exchange(<r1-6>)[
    Table 1 should report the standardized mean difference, not just
    raw means, to demonstrate balance.
  ][
    We have adjusted the "after weighting" age estimate for consistency
    with the balance figure; a full standardized mean difference table
    is shown in @fig-smd. 
    
    #pinpoint(<r1-6>, excerpt: true)
  ]

  #exchange(<r1-9>)[
    The calibration equation seems redundant with equation 1.
  ][
    We agree and have removed it. 
    
    #pinpoint(<r1-9>, excerpt: true)
  ]

  #exchange(<r1-10>)[
    Please report sensitivity to the truncation threshold.
  ][
    This was explored early on but is redundant with the E-value
    analysis and has been removed for concision.

    #pinpoint(<r1-10>, excerpt: true)
  ]

  #exchange(<r1-7>)[
    An unmeasured confounding sensitivity analysis is missing.
  ][
    An E-value sensitivity analysis has been added, following the
    recommendations cited in the manuscript. #pinpoint(<r1-7>)
  ]

  #exchange(<r1-8>)[
    The conclusion should not overstate causal language given the
    observational design.
  ][
    We have reviewed the conclusion and believe the current wording,
    already qualified throughout the discussion, remains appropriate;
    we have therefore left it unchanged. 
    
    #pinpoint(<r1-8>, excerpt: true)
  ]

]

#pagebreak()

#reviewer(2)[

  #exchange(<r2-1>)[
    The methods section heading should indicate that methods were
    updated relative to the registered protocol.
  ][
    The heading has been updated accordingly. 
    
    #pinpoint(<r2-1>, excerpt: true)
  ]

  #exchange(<r2-2>)[
    Please add a covariate balance figure (e.g. a Love plot) to support
    the claim that weighting achieved adequate balance.
  ][
    A standardized mean difference figure has been added.

    #pinpoint(<r2-2>, excerpt: true)
  ]

  #exchange(<r2-3>)[
    The per-protocol analysis is not pre-specified and, given space
    constraints, could be removed to focus the paper on the primary
    intention-to-treat-style emulation.
  ][
    We agree and have removed the per-protocol subsection in its
    entirety, including its figure and table.
    
    #pinpoint(<r2-3>, excerpt: true)
  ]

  #exchange(<r2-4>)[
    The discussion's caution about the observational design could
    acknowledge the target trial framework's mitigating role more
    explicitly.
  ][
    We have expanded this sentence accordingly, as already discussed in
    our response to #xcomment(<r1-2>) on the choice of confounder
    selection criterion. 
    
    #pinpoint(<r2-4>, excerpt: true)
  ]

]

#pagebreak()

#editor[

  #exchange(<e1>)[
    Please ensure all figures referenced in the text include a page
    citation in the response letter, per journal policy.
  ][
    Done throughout; see e.g. the balance figure, referenced at
    #xref(<fig-smd>), and the baseline table, referenced at
    #xref(<tab-baseline>).
  ]

]

== For the reviewers only

The figure below summarizes, for the reviewers' convenience only, how many
comments from each reviewer led to a textual change versus a clarification
without a change to the manuscript.

#figure(
  table(
    columns: 3,
    table.header[Reviewer][Comments][Textual changes],
    [Reviewer 1], [8], [6],
    [Reviewer 2], [4], [4],
  ),
  caption: [Summary of comments and changes, for the reviewers' convenience.],
) <tab-summary>

As shown in @tab-summary, most comments led to a direct textual change,
with a smaller number addressed by clarification alone
(as discussed by #cite(<schneeweiss2018>, form: "prose") in a related
methodological context). We also note the sensitivity-analysis literature
more broadly #cite(<jones2021>, form: "prose").

#letter-bibliography("/tests/bundle-ieee/responses.bib")
