#import "lib/elteikthesis.typ": thesis, todo

#show: thesis.with(
  university: "Eötvös Loránd Tudományegyetem",
  faculty: "Informatikai kar",
  department: "Számítógéptudományi Tenszék",

  title: [
    Evolutionary Technology:

    Replication of the FATINT system
  ],

  author: "Szabin Hamrik",
  degree: "Programtervező informatikus BSc",

  supervisor: "László Gulyás Dr.",
  affiliation: "Mesterséges Intelligencia Tanszék",

  city: "Budapest",
  year: "2026",

  language: "hu",

  finalized: false,
)

#todo("Assert that the NetLogo implementation requires NetLogo 6 and was not tested with NetLogo 7")
#todo("Tidy up NetLogo implementation and run experiments. Also measure performance of both implementations, with varying inputs")
#todo("Add test plan for NetLogo")
#todo("Add rationale behind the C++ reimplementation, compare accuracy and performance VS NetLogo")
#todo("Add system architecture diagram for C++ implementation")
#todo("Add doc comments and generate doxygen docs for C++ implementation")
#todo("Make disclaimer about the thesis template file being converted from the official LaTeX template using AI")
#todo("Embed results, draw conclusions")

#include "chapters/introduction/main.typ"
#include "chapters/user_manual/main.typ"
#include "chapters/developer_documentation/main.typ"

#bibliography("thesis.bib")
