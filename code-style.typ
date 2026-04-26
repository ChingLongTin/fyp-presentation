#import "theme.typ": primary-color, contrast-color

#let pc(it) = text(fill: primary-color, it)
#let cc(it) = text(fill: contrast-color, it)

#let styling(it) = {

  set list(
    marker: ([‣], [•], [-]),
    indent: 1em,
    spacing: 0.65em,
  )

  show raw.where(block: true): it => {
    set par(leading: 0.6em)
    set text(size: 0.9em)
    it
  }

  show raw.where(block: false): it => {
    set text(size: 0.9em)
    it
  }
  
  show heading.where(level: 3): set heading(numbering: none, outlined: false)
  

  it
}
