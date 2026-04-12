#import "../common/styles.typ": *

#let data = if "data" in sys.inputs {
  json(sys.inputs.data)
} else {
  none
}

#let page-width = data.document.width_pt * 1pt
#let page-height = data.document.height_pt * 1pt
#let title = data.diagram.title
#let subtitle = data.diagram.subtitle

#set page(
  width: page-width,
  height: page-height,
  margin: 0pt,
  fill: rgb(data.document.background),
)

#set text(font: "Inter", size: 10pt, lang: "de")

#let draw-segment(segment, color) = place(
  top + left,
  dx: segment.start_x_pt * 1pt,
  dy: segment.start_y_pt * 1pt,
  line(
    end: (
      (segment.end_x_pt - segment.start_x_pt) * 1pt,
      (segment.end_y_pt - segment.start_y_pt) * 1pt,
    ),
    stroke: (paint: rgb(color), thickness: 1.2pt, cap: "round"),
  ),
)

#let draw-label(node) = place(
  top + left,
  dx: node.x_pt * 1pt,
  dy: node.y_pt * 1pt,
  block(
    width: node.width_pt * 1pt,
    height: node.height_pt * 1pt,
    inset: (x: 10pt, y: 8pt),
  )[
    #set align(center + horizon)
    #set text(size: 9pt, weight: "medium", fill: rgb(node.text))
    #node.label
  ],
)

#let draw-node(node) = {
  if node.shape == "circle" {
    let radius = calc.min(node.width_pt, node.height_pt) / 2 * 1pt
    place(
      top + left,
      dx: node.x_pt * 1pt,
      dy: node.y_pt * 1pt,
      circle(
        radius: radius,
        fill: rgb(node.fill),
        stroke: 1pt + rgb(node.stroke),
      ),
    )
  } else if node.shape == "diamond" {
    let side = calc.min(node.width_pt, node.height_pt) * 0.82 * 1pt
    place(
      top + left,
      dx: (node.x_pt + (node.width_pt - calc.min(node.width_pt, node.height_pt) * 0.82) / 2) * 1pt,
      dy: (node.y_pt + (node.height_pt - calc.min(node.width_pt, node.height_pt) * 0.82) / 2) * 1pt,
      rotate(
        45deg,
        square(
          size: side,
          fill: rgb(node.fill),
          stroke: 1pt + rgb(node.stroke),
        ),
      ),
    )
  } else {
    place(
      top + left,
      dx: node.x_pt * 1pt,
      dy: node.y_pt * 1pt,
      block(
        width: node.width_pt * 1pt,
        height: node.height_pt * 1pt,
        inset: 0pt,
        radius: if node.shape == "rounded" { 14pt } else { 4pt },
        fill: rgb(node.fill),
        stroke: 1pt + rgb(node.stroke),
      )[],
    )
  }

  draw-label(node)
}

#let draw-edge(edge) = {
  for segment in edge.segments {
    draw-segment(segment, edge.stroke)
  }

  if edge.label != none {
    place(
      top + left,
      dx: edge.label_x_pt * 1pt - 36pt,
      dy: edge.label_y_pt * 1pt - 10pt,
      block(
        width: 72pt,
        inset: (x: 6pt, y: 3pt),
        radius: 6pt,
        fill: white,
      )[
        #set align(center + horizon)
        #set text(size: 8pt, fill: rgb(edge.stroke))
        #edge.label
      ],
    )
  }
}

#let draw-zone(zone) = place(
  top + left,
  dx: zone.x_pt * 1pt,
  dy: zone.y_pt * 1pt,
  block(
    width: zone.width_pt * 1pt,
    height: zone.height_pt * 1pt,
    inset: (x: 10pt, y: 8pt),
    radius: 10pt,
    fill: rgb(zone.fill),
    stroke: 0.8pt + rgb(zone.stroke),
  )[
    #set text(size: 8pt, weight: "bold", fill: rgb(zone.text))
    #zone.label
  ],
)

#block(width: page-width, height: page-height, inset: 0pt)[
  #if title != none {
    place(
      top + left,
      dx: data.document.margin_pt * 1pt,
      dy: 18pt,
      text(size: 20pt, weight: "bold", fill: rgb("#0f172a"))[#title],
    )
  }

  #if subtitle != none {
    place(
      top + left,
      dx: data.document.margin_pt * 1pt,
      dy: 42pt,
      text(size: 9pt, fill: rgb("#475569"))[#subtitle],
    )
  }

  #for zone in data.zones {
    draw-zone(zone)
  }

  #for edge in data.edges {
    draw-edge(edge)
  }

  #for node in data.nodes {
    draw-node(node)
  }
]
