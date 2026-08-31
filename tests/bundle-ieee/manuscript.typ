#import "../../lib.typ": *

= Introduction

#lorem(120)

#passage(<r1-1>)[
  Propensity score methods #add[, including inverse probability weighting and matching,] have become a standard approach for confounding control in observational studies #cite(<austin2011>).
]

#passage(<r1-11>)[
  #add[This revision responds to a single comment that required changes in two separate sections of the manuscript — this sentence, in the introduction,] is one of them.
]

#lorem(150)

#passage(<r1-2>)[
  #rep[Confounders were selected based on prior clinical knowledge.][Confounders were selected using the disjunctive cause criterion described by @vanderweele2019, and prior clinical knowledge was used only as a secondary check.]
]

#lorem(100)

= #passage(<r2-1>)[Méthodes #add[actualisées]]

#lorem(80)

#passage(<r1-3>)[
  The target trial emulation followed the cloning, censoring, and weighting approach #add[described by @hernan2016].
]

#touched(<r1-4>)[
  Patients were followed from cohort entry until the earliest of death, loss to follow-up, or administrative censoring.
]

#lorem(60)

#passage(<r1-5>)[
  The propensity score was estimated as
  #rep[$ pi(x) = P(A=1 | X=x) $][
    $ pi(x) = P(A = 1 | X = x, t_0) $ <eq-ps>
  ]
  using logistic regression #add[with restricted cubic splines for continuous covariates].
]

#lorem(140)

#added(<r2-2>)[
  #figure(
    rect(width: 70%, height: 3cm, fill: luma(235), stroke: 0.5pt),
    caption: [Standardized mean differences before and after weighting.],
  ) <fig-smd>
]

#lorem(90)

In @fig-smd, the covariate balance is shown before and after inverse probability weighting.

= Résultats

#lorem(100)

#passage(<r1-6>)[
  #figure(
    placement: none,
    table(
      columns: 3,
      table.header[Covariate][Before weighting][After weighting],
      [Age, years], [54.2 (12.1)], [#rep[54.0 (11.9)][54.1 (12.0)]],
      [Sex, \% female], [48.3], [48.1],
      [Diabetes, \%], [22.7], [21.9],
    ),
    caption: [Baseline characteristics before and after weighting.],
  ) <tab-baseline>
]

#lorem(120)

#suppressed(
  <r2-3>,
  [Section supprimée : l'ancienne analyse per-protocole, y compris la figure et le tableau associés],
  summary: [l'ancienne analyse per-protocole, y compris la figure et le tableau associés],
)

#lorem(40)

#deleted(<r1-9>, summary: [l'équation de calibration, devenue redondante avec l'équation 1])[
  $ hat(pi)(x) = "expit"(beta_0 + beta_1 x) $ <eq-calib>
]

#lorem(40)

#suppressed(
  <r1-10>,
  [Tableau supprimé : sensibilité au seuil de troncature],
  summary: [le tableau de sensibilité au seuil de troncature],
)

#lorem(160)

#passage(<r1-7>)[
  A sensitivity analysis using E-values #add[was conducted to assess robustness to unmeasured confounding, as recommended by @vanderweele2019].
]

#lorem(200)

= Discussion

#lorem(180)

#passage(<r2-4>)[
  #rep[These results should be interpreted with caution given the observational design.][These results should be interpreted in light of the observational design, though the target trial framework mitigates several sources of bias common to such analyses.]
]

#lorem(150)

= Conclusion

#lorem(70)

#touched(<r1-8>)[
  We conclude that early treatment initiation was associated with improved outcomes in this emulated trial.
]

#passage(<r1-11>)[
  #add[This sentence, in the conclusion, was the second of the two changes made in response to that same comment.]
]
