#import "lib/elteikthesis.typ": thesis

#thesis(
  language: "hu",

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

  finalized: true,
)[
  #include "chapters/introduction/main.typ"
  #include "chapters/netlogo/main.typ"
  #include "chapters/cpp/main.typ"
  #include "chapters/summary/main.typ"

  #outline(
    title: [Definíciók listája],
    target: figure.where(kind: "definition"),
  )

  #outline(
    title: [Ábrák listája],
    target: figure.where(kind: image),
  )

  #outline(
    title: [Táblázatok listája],
    target: figure.where(kind: table),
  )

  #outline(
    title: [Kódrészletek listája],
    target: figure.where(kind: "listing")
      .or(figure.where(kind: "command"))
      .or(figure.where(kind: "source")),
  )

  #bibliography("thesis.bib")
]
