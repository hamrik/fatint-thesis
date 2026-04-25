#import "lib/elteikthesis.typ": thesis, todo

#show: thesis.with(
  university: "Eötvös Loránd Tudományegyetem",
  faculty: "Informatikai kar",
  department: "Mesterséges Intelligencia Tanszék",

  title: [
    Evolutionary Technology:

    Replication of the FATINT system
  ],

  author: "Hamrik Szabin",
  degree: "Programtervező informatikus BSc",

  supervisor: "Gulyás László",
  affiliation: "Mesterséges Intelligencia Tanszék",

  city: "Budapest",
  year: "2026",

  language: "hu",

  finalized: false,
)

#todo("Add test plan for NetLogo")
#todo("Add doc comments and generate doxygen docs for C++ implementation")
#todo("Make disclaimer about the thesis template file being converted from the official LaTeX template using AI")

#include "chapters/introduction/main.typ"
#include "chapters/user_manual/main.typ"
#include "chapters/developer_documentation/main.typ"
#include "chapters/results/main.typ"

#bibliography("thesis.bib")
