/// ELTE FI Thesis Template for Typst

// Initially converted from the LaTeX template at
// https://github.com/mcserep/elteikthesis
// using Claude Sonnet 4.6,
// then havily modified by hand

/// Setup ELTE FI thesis layout
#let thesis(
  title: "Thesis Title",
  author: "Author Name",
  degree: "Degree Name",
  supervisor: "Supervisor Name",
  affiliation: "Affiliation",
  ext-supervisor: none,
  ext-affiliation: none,
  university: "Eötvös Loránd University",
  faculty: "Faculty of Informatics",
  department: "Department of Computer Science",
  city: "Budapest",
  year: "2024",
  language: "en",
  logo: "elte_cimer_szines.svg",
  finalized: true,
  body
) = {

  // Language-specific labels
  let labels = if language == "hu" {
    (
      author: "Szerző",
      supervisor: "Témavezető",
      int-supervisor: "Belső témavezető",
      ext-supervisor: "Külső témavezető",
      outline: "Tartalomjegyzék",
      definition: "Definíció",
      theorem: "Tétel",
      remark: "Emlékeztető",
      note: "Megjegyzés",
      code: "forráskód",
      algorithm: "algoritmus",
      bibliography: "Irodalomjegyzék",
      list-of-algorithms: "Algoritmusjegyzék",
      list-of-figures: "Ábrajegyzék",
      list-of-tables: "Táblázatjegyzék",
      list-of-codes: "Forráskódjegyzék",
      acknowledgements: "Köszönetnyilvánítás",
      not-finalized: "Nem végleges!",
    )
  } else {
    (
      author: "Author",
      supervisor: "Supervisor",
      int-supervisor: "Internal supervisor",
      ext-supervisor: "External supervisor",
      outline: "Table of contents",
      definition: "Definition",
      theorem: "Theorem",
      remark: "Remark",
      note: "Note",
      code: "Code",
      algorithm: "Algorithm",
      bibliography: "Bibliography",
      list-of-algorithms: "List of Algorithms",
      list-of-figures: "List of Figures",
      list-of-tables: "List of Tables",
      list-of-codes: "List of Codes",
      acknowledgements: "Acknowledgements",
      not-finalized: "Not finalized!"
    )
  }

  // Set document metadata
  set document(title: title, author: author)

  // Set text language
  set text(lang: language, size: 12pt)

  // Page setup: A4 with specified margins
  set page(
    paper: "a4",
    margin: (left: 35mm, right: 25mm, top: 25mm, bottom: 25mm),
    header-ascent: 16pt,
    numbering: "1",
    header: context {
      let page-num = here().page()
      // No header on first page (cover) and TOC pages
      if page-num > 1 and counter(page).get().first() > 0 [
        #set text(style: "italic", size: 11pt)
        #line(length: 100%, stroke: 1pt)
        #v(-8pt)
        #context {
          let elems = query(selector(heading.where(level: 1)).before(here()))
          if elems.len() > 0 {
            let chapter = elems.last()
            [#counter(heading).at(chapter.location()).first(). #chapter.body]
          }
        }
      ]
    },
    footer: context {
      let page-num = counter(page).get().first()
      if page-num > 0 [
        #align(center)[#page-num]
      ]
    }
  )

  // Paragraph settings
  set par(
    justify: true,
    leading: 0.65em, // Approximates 1.427465 line spacing
    first-line-indent: 3.5em,
  )

  // Heading settings
  set heading(numbering: "1.1", supplement: none)

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1em)
    set text(size: 18pt, weight: "bold")
    block[
      #counter(heading).display() #it.body
    ]
    v(0.5em)
  }

  show heading.where(level: 2): it => {
    v(0.8em)
    set text(size: 14pt, weight: "bold")
    block[
      #counter(heading).display() #it.body
    ]
    v(0.4em)
  }

  show heading.where(level: 3): it => {
    v(0.6em)
    set text(size: 12pt, weight: "bold")
    block[
      #counter(heading).display() #it.body
    ]
    v(0.3em)
  }

  set cite(form: "prose")

  show link: it => {
    set text(fill: blue.darken(30%))
    [
      #underline(it)
      #footnote(it.dest)
    ]
  }

  // Figure and table captions
  show figure.caption: it => {
    align(center)[
      #it
    ]
  }

  // Formula numbering
  set math.equation(numbering: n => [(#n)], supplement: none)

  // Code blocks styling
  show raw.where(block: true): it => {
    set text(size: 10pt)//, font: "Courier New")
    block(
      fill: rgb("#f2f2f2"),
      width: 100%,
      inset: 8pt,
      radius: 2pt,
      stroke: 0.5pt + rgb("#cccccc"),
      it
    )
  }

  // COVER PAGE
  page(
    margin: (left: 25mm, right: 25mm, top: 25mm, bottom: 25mm),
    header: none,
    footer: none,
    numbering: none,
  )[
    #set align(center)
    #set par(first-line-indent: 0em)

    #grid(
      columns: (1fr, 3fr),
      align: (left, left),
      gutter: 10pt,
      image(logo, width: 60%),
      [
        #v(5pt)
        #text(size: 14pt, weight: "bold")[#university] \
        #v(3pt)
        #text(size: 14pt, weight: "bold")[#faculty] \
        #v(5pt)
        #text(size: 12pt)[#department]
      ]
    )

    #v(5cm)

    #text(size: 20pt, weight: "bold")[#title]

    #if finalized != true {
      text(size: 18pt, weight: "bold", fill: rgb("#ff0000"))[#labels.not-finalized]
    }

    #v(4cm)

    #if ext-supervisor != none {
      text(size: 12pt, style: "italic")[#labels.author:]
      text(size: 12pt)[#author]
      text(size: 11pt)[#degree]

      v(2cm)

      grid(
        columns: (1fr, 1fr),
        gutter: 40pt,
        align: center,
        [
          #text(size: 12pt, style: "italic")[#labels.int-supervisor:] \
          #text(size: 12pt)[#supervisor] \
          #text(size: 10pt)[#affiliation]
        ],
        [
          #text(size: 12pt, style: "italic")[#labels.ext-supervisor:] \
          #text(size: 12pt)[#ext-supervisor] \
          #text(size: 10pt)[#ext-affiliation]
        ]
      )
    } else {
      v(1cm)
      grid(
        columns: (1fr, 1fr),
        gutter: 40pt,
        align: center,
        [
          #text(size: 12pt, style: "italic")[#labels.supervisor:] \
          #text(size: 12pt)[#supervisor] \
          #text(size: 10pt)[#affiliation]
        ],
        [
          #text(size: 12pt, style: "italic")[#labels.author:] \
          #text(size: 12pt)[#author] \
          #text(size: 10pt)[#degree]
        ]
      )
    }

    #v(1fr)

    #text(size: 12pt, style: "italic")[#city, #year]
  ]

  // TABLE OF CONTENTS
  page(
    numbering: none,
    header: none,
  )[
    #outline(
      title: labels.outline,
      indent: auto,
      depth: 3
    )
  ]

  // Reset page numbering for main content
  counter(page).update(1)

  // Main document body
  body
}

/// Render a definition block
#let definition(body, title: none) = {
  block(
    fill: rgb("#f0f0f0"),
    width: 100%,
    inset: 10pt,
    radius: 3pt,
    [
      #if title != none [
        #text(weight: "bold")[ #title: ]
      ]
      #body
    ]
  )
}

/// Render a theorem block
#let theorem(body, title: none) = {
  let label = if (context text.lang) == "hu" { "Tétel" } else { "Theorem" }
  block(
    stroke: 1pt,
    width: 100%,
    inset: 10pt,
    radius: 3pt,
    [
      #text(weight: "bold")[
        #label
        #if title != none [ (#title)]
        :
      ]
      #text(style: "italic")[#body]
    ]
  )
}

/// Render a remark block
#let remark(body, title: none) = {
  let label = if (context text.lang) == "hu" { "Megjegyzés" } else { "Remark" }
  block(
    inset: 10pt,
    [
      #text(weight: "bold", style: "italic")[
        #label
        #if title != none [ (#title)]
        :
      ]
      #body
    ]
  )
}

/// Alias for `remark()`
#let note(body, title: none) = remark(body, title: title)

/// Render a warning block
#let warning(body) = [
  #let rblock = block.with(stroke: orange, radius: 0.5em, fill: orange.lighten(80%))
  #block(inset: (top: 0.35em), {
    rblock(width: 100%, inset: 1em, body)
  })
  <todo>
]

/// Render a todo block
#let todo(body) = [
  #let rblock = block.with(stroke: red, radius: 0.5em, fill: red.lighten(80%))
  #let top-left = place.with(top + left, dx: 1em, dy: -0.35em)
  #block(inset: (top: 0.35em), {
    rblock(width: 100%, inset: 1em, body)
    top-left(rblock(fill: white, outset: 0.25em, text(fill: red)[*TODO*]))
  })
  <todo>
]
