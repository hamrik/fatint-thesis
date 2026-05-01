#import "lib/elteikthesis.typ": thesis

#show: thesis.with(
  university: "Eötvös Loránd Tudományegyetem",
  faculty: "Informatikai kar",
  department: "Mesterséges Intelligencia Tanszék",

  title: [
    #text("Evolutionary Technology:", lang: "en")

    #text("Replication of the FATINT system", lang: "en")
  ],

  author: "Hamrik Szabin",
  degree: "Programtervező informatikus BSc",

  supervisor: "Dr. Gulyás László",
  affiliation: "Mesterséges Intelligencia Tanszék",

  city: "Budapest",
  year: "2026",

  language: "hu",

  finalized: true,
)

#include "chapters/introduction/main.typ"
#include "chapters/netlogo/main.typ"
#include "chapters/cpp/main.typ"

#bibliography("thesis.bib")
