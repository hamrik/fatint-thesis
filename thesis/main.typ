#import "lib/elteikthesis.typ": thesis

#show: thesis.with(
  title: "Evolutionary Technology: Replication of the FATINT System",

  author: "Szabin Hamrik",
  degree: "Computer Science BSc",

  supervisor: "László Gulyás Dr.",
  affiliation: "Department of Artificial Intelligence",

  city: "Budapest",
  year: "2026",

  language: "en",

  finalized: false,
)

#include "chapters/introduction.typ"
#include "chapters/user_manual/main.typ"
#include "chapters/developer_documentation/main.typ"

#bibliography("thesis.bib")
