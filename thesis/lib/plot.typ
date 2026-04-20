#let avg_species_plot(src, prop:none, steps:6000, cap:5) = {
  import "@preview/lilaq:0.6.0" as lq

  let data = lq.load-txt(read(src), header: true)

  let plot_slice = i => lq.plot(
    data.step.slice(i * steps, (i + 1) * steps),
    data.average_species_count.slice(i * steps, (i + 1) * steps),
    label: if prop != none { [#prop = #data.at(prop).at(i * steps)] } else { none },
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
    ylim: (0, cap),
    legend: if prop != none { (position: (100% + 1em, 0%)) } else { none },
    cycle: (
      (mark: ".", color: lq.color.map.petroff10.at(0)),
      (mark: "x", color: lq.color.map.petroff10.at(1)),
      (mark: "a3", color: lq.color.map.petroff10.at(2)),
      (mark: "a4", color: lq.color.map.petroff10.at(3)),
      (mark: "a5", color: lq.color.map.petroff10.at(4)),
      (mark: "a6", color: lq.color.map.petroff10.at(5)),
      (mark: "s", color: lq.color.map.petroff10.at(6)),
      (mark: "d", color: lq.color.map.petroff10.at(7)),
      (mark: "^", color: lq.color.map.petroff10.at(8)),
      (mark: "v", color: lq.color.map.petroff10.at(9)),
      (mark: "x", color: lq.color.map.petroff10.at(0)),
      (mark: "a3", color: lq.color.map.petroff10.at(1)),
      (mark: "a4", color: lq.color.map.petroff10.at(2)),
      (mark: "a5", color: lq.color.map.petroff10.at(3)),
      (mark: "a6", color: lq.color.map.petroff10.at(4)),
      (mark: "s", color: lq.color.map.petroff10.at(5)),
      (mark: "d", color: lq.color.map.petroff10.at(6)),
      (mark: "^", color: lq.color.map.petroff10.at(7)),
      (mark: "v", color: lq.color.map.petroff10.at(8)),
      (mark: ".", color: lq.color.map.petroff10.at(9))
    ),
    ..range(exp_count).map(i => plot_slice(i))
  )
}
