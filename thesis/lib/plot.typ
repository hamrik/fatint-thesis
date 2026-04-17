#let avg_species_plot(src, prop, steps:6000) = {
  import "@preview/lilaq:0.6.0" as lq

  let data = lq.load-txt(read(src), header: true)

  let plot_slice = i => lq.plot(
    data.step.slice(i * steps, (i + 1) * steps),
    data.average_species_count.slice(i * steps, (i + 1) * steps),
    label: [#prop = #data.at(prop).at(i * steps)],
    stroke: none
  )

  let exp_count = int(data.step.len() / steps)

  lq.diagram(
    width: 10cm,
    height: 6cm,
    xlabel: "Kör",
    xaxis: (exponent: 0),
    ylabel: "Fajok átlagos száma",
    yaxis: (exponent: 0),
    legend: (position: (100% + 1em, 0%)),
    ..range(exp_count).map(i => plot_slice(i))
  )
}
