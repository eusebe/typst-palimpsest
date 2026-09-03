#import "../../lib.typ": *
#import "@preview/charged-ieee:0.1.4": ieee

#show: revisions.with(
  template: ieee.with(
    title: [Emulating a Target Trial of Early Treatment Initiation: A Propensity Score Analysis],
    abstract: [
      We emulate a target trial of early treatment initiation using
      observational data and propensity score methods. This revised
      manuscript addresses reviewer comments on confounder selection,
      the propensity score model specification, covariate balance
      reporting, and an unmeasured confounding sensitivity analysis.
    ],
    authors: (
      (
        name: "D. Hajage",
        department: [Department of Biostatistics],
        organization: [Sorbonne Université],
        location: [Paris, France],
        email: "d.hajage@example.org",
      ),
    ),
    index-terms: ("Target trial emulation", "Propensity score", "Confounding", "Observational data"),
    bibliography: bibliography("manuscript.bib"),
    figure-supplement: [Fig.],
  ),
  exchanges: include "responses.typ",
  round: 1,
)

#include "manuscript.typ"
