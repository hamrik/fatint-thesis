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

  supervisor: "Dr. Gulyás László",
  affiliation: "Mesterséges Intelligencia Tanszék",

  city: "Budapest",
  year: "2026",

  language: "hu",

  finalized: false,
)

#include "chapters/introduction/main.typ"
#include "chapters/netlogo/main.typ"
#include "chapters/cpp/main.typ"

#bibliography("thesis.bib")
