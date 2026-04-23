#import "@preview/lilaq:0.6.0" as lq

#let MARKS = (
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
)

#let plot_ranges(data, prop) = {
  let ranges = ()
  let prev_val = data.at(prop).at(0)
  let range_start = 0
  for (i, row) in data.at(prop).enumerate() {
    if row != prev_val {
      ranges.push((range_start, i))
      range_start = i
      prev_val = row
    }
  }
  ranges.push((range_start, -1))
  return ranges
}

#let netlogo_species_plot(src, prop, cap: 5) = {
  let data = lq.load-txt(
    read(src),
    skip-rows: 7,
    converters: it => if it == "\"N/A\"" {
      none
    } else {
      float(it.slice(1, -1))
    }
  )

  let plot_slice = ((from,to)) => {
    let label = if prop != none {
      [#prop = #data.at(0).at(from)]
    } else {
      none
    }
    lq.plot(
      data.at(1).slice(from, to),
      data.at(2).slice(from, to),
      label: label,
      stroke: none
    )
  }

  lq.diagram(
    title: "NetLogo 6.4.0",
    width: 10cm,
    height: 5cm,
    xlabel: "Kör",
    xaxis: (exponent: 0),
    ylabel: "Fajok átlagos száma",
    yaxis: (exponent: 0),
    ylim: (0, cap),
    legend: if prop != none { (position: (100% + 1em, 0%)) } else { none },
    cycle: MARKS,
    ..plot_ranges(data, 0).map(plot_slice)
  )
}

#let libfatint_species_plot(src, prop, cap:5, legend:true) = {
  let data = lq.load-txt(read(src), header: true)

  let plot_slice = ((from,to)) => {
    let label = if legend and prop != none {
      [#raw(prop) = #data.at(prop).at(from)]
    } else {
      none
    }
    lq.plot(
      data.step.slice(from, to),
      data.average_species_count.slice(from, to),
      label: label,
      stroke: none
    )
  }

  let plots = if prop != none {
    plot_ranges(data, prop).map(plot_slice)
  } else {
    plot_ranges(data, "starting_population").map(plot_slice)
  }

  let legend_def = if legend and prop != none {
    (position: (100% + 1em, 0%))
  } else {
    none
  }

  lq.diagram(
    title: "libfatint",
    width: 10cm,
    height: 5cm,
    xlabel: "Kör",
    xaxis: (exponent: 0),
    ylabel: "Fajok átlagos száma",
    yaxis: (exponent: 0),
    ylim: (0, cap),
    legend: legend_def,
    cycle: MARKS,
    ..plots
  )
}

#let netlogo_species_counter_perf_plot(srcs) = {
  let plot_chunk = (src) => {
    let data = lq.load-txt(
      read(src.path),
      skip-rows: 7,
      converters: it => if it == "\"N/A\"" {
        none
      } else {
        float(it.slice(1, -1))
      }
    );
    lq.plot(label: src.label, data.at(0), data.at(2))
  }

  lq.diagram(
    title: "NetLogo 6.4.0",
    width: 10cm,
    height: 5cm,
    xlabel: "Populáció mérete",
    // xscale: "log",
    ylabel: "Fajszámlálás időigénye (ms)",
    // yscale: "log",
    legend: (position: (100% + 1em, 0%)),
    cycle: MARKS,
    ..srcs.map(plot_chunk)
  )
}

#let libfatint_species_counter_perf_plot(srcs) = {
  let plot_chunk = (src) => {
    let data = lq.load-txt(read(src.path));
    lq.plot(label: src.label, data.at(0), data.at(1))
  }

  lq.diagram(
    title: "libfatint",
    width: 10cm,
    height: 5cm,
    xlabel: "Populáció mérete",
    xscale: "log",
    ylabel: "Fajszámlálás időigénye (ms)",
    yscale: "log",
    legend: (position: (100% + 1em, 0%)),
    cycle: MARKS,
    ..srcs.map(plot_chunk)
  )
}

#let netlogo_simulator_perf_plot(srcs) = {
  let plot_chunk = (src) => {
    let data = lq.load-txt(
      read(src.path),
      skip-rows: 7,
      converters: it => if it == "\"N/A\"" {
        none
      } else {
        float(it.slice(1, -1))
      }
    );
    lq.plot(label: src.label, data.at(0), data.at(2))
  }

  lq.diagram(
    title: "libfatint",
    width: 10cm,
    height: 5cm,
    xlabel: [$E_"increase"$],
    //xscale: "log",
    ylabel: "500 körös szimuláció időigénye (ms)",
    //yscale: "log",
    ..srcs.map(plot_chunk)
  )
}

#let libfatint_simulator_perf_plot(srcs) = {
  let plot_chunk = (src) => {
    let data = lq.load-txt(read(src.path));
    lq.plot(label: src.label, data.at(0), data.at(1))
  }

  lq.diagram(
    title: "libfatint",
    width: 10cm,
    height: 5cm,
    xlabel: [$E_"increase"$],
    //xscale: "log",
    ylabel: "1000 körös szimuláció időigénye (ms)",
    //yscale: "log",
    ..srcs.map(plot_chunk)
  )
}
