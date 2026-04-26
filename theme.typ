// University theme

// Originally contributed by Pol Dellaiera - https://github.com/drupol

#import "@preview/touying:0.6.1": *
#import "custom-outline.typ": custom-outline

#let text-color = black
#let primary-color = green.darken(40%)
#let contrast-color = rgb("#05958c")

#let should-hide = state("cover-style-hide", false)
#let hide() = context should-hide.update(true)
#let shade() = context should-hide.update(false)
#let cover-it(self: none, it) = context if should-hide.get() {
  utils.semi-transparent-cover(it, self: self, alpha: 100%)
} else {
  utils.semi-transparent-cover(it, self: self, alpha: 95%)
}

/// Default slide function for the presentation.
///
/// - `config` is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - `repeat` is the number of subslides. Default is `auto`，which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - `setting` is the setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - `composer` is the composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - `..bodies` is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let header(self) = {
    set align(top)
    if self.store.progress-bar {
      components.progress-bar(height: 2pt, self.colors.primary, self.colors.tertiary)
    }
    set align(horizon)
    grid(
      rows: (auto, auto),
      row-gutter: 3mm,
      block(
        inset: (x: 2em),
        components.left-and-right(
          text(fill: self.colors.primary, weight: "bold", size: 1.2em, utils.call-or-display(self, self.store.header)),
          text(fill: self.colors.primary.lighten(65%), utils.call-or-display(self, self.store.header-right)),
        ),
      ),
    )
    // Extra bottom gap below header to space slide content
    v(self.store.header-bottom-gap)
  }
  let footer(self) = {
    set align(center + bottom)
    // Slightly smaller footer text
    set text(size: 0.4em)
    {
      let cell(..args, it) = components.cell(
        ..args,
        align(horizon, text(fill: white, it)),
      )
      // Reduce footer block height slightly
      show: block.with(width: 100%, height: 1.4em)
      grid(
        columns: self.store.footer-columns,
        cell(fill: self.colors.primary, utils.call-or-display(self, self.store.footer-a)),
        cell(fill: self.colors.secondary, utils.call-or-display(self, self.store.footer-b)),
        cell(fill: self.colors.tertiary, utils.call-or-display(self, self.store.footer-c)),
      )
    }
  }
  let footer-fn = if self.store.show-footer {
    footer
  } else {
    none
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer-fn,
    ),
  )
  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: university-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.school,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle])
/// ```
///
/// - `extra` is the extra information of the slide. You can pass the extra information to the `title-slide` function.
#let title-slide(
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  info.authors = {
    let authors = if "authors" in info {
      info.authors
    } else {
      info.author
    }
    if type(authors) == array {
      authors
    } else {
      (authors,)
    }
  }
  let body = {
    if info.logo != none {
      place(right, text(fill: self.colors.primary, info.logo))
    }
    /// place(top + left, image("images/UST_L3.png", width: 50%))
    
    align(
      left + horizon,
      block(
        inset: 0em,
        breakable: false,
        {
          v(3em)
          set par(leading: 0.4em)
          text(size: 1.6em, fill: self.colors.primary, weight: "bold", info.title)
          linebreak()
          // align(right, 
          //   text(size: 1.0em, fill: self.colors.primary, [(Lecture #info.lecture-number)])
          // )
          v(0.7em)
          text(size: 1.0em, info.subtitle) 
          text(", ")
          text(size: 1.0em, info.date) 
          v(0em)
          text(size: 1.0em, fill: self.colors.primary, info.author)
        }
      )
    )
  }
  // Allow disabling the footer via store flag
  let cfgArgs = (:)
  if not self.store.show-footer {
    cfgArgs.footer = none
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.neutral-lightest, ..cfgArgs),
  )
  touying-slide(self: self, body)
})


/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - `level` is the level of the heading.
///
/// - `numbered` is whether the heading is numbered.
///
/// - `body` is the body of the section. It will be pass by touying automatically.
#let new-section-slide(level: 1, numbered: true, body) = touying-slide-wrapper(self => {
  let slide-body = {
    set align(horizon)
    show: pad.with(left: 10%, right: 10%)
    
    custom-outline(
      title: none,
      // fill: none,
      filter: hd => hd.relation != none and not hd.relation.unrelated,
      depth: 2,
      transform: (hd, it) => {
        set text(size: 1.25em, fill: self.colors.primary, weight: "bold") if hd.relation != none and hd.relation.same
        set text(fill: self.colors.primary) if hd.relation != none and hd.relation.child
        set text(fill: text.fill.transparentize(60%)) if hd.relation != none and hd.relation.sibling
        
        it
      },
    )
    
    body
  }
  // Allow disabling the footer via store flag
  let cfgArgs = (:)
  if not self.store.show-footer {
    cfgArgs.footer = none
  }
  self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.neutral-lightest, ..cfgArgs),
  )
  touying-slide(self: self, slide-body)
})


/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
/// - `background-color` is the background color of the slide. Default is the primary color.
///
/// - `background-img` is the background image of the slide. Default is none.
#let focus-slide(background-color: none, background-img: none, body) = touying-slide-wrapper(self => {
  let background-color = if background-img == none and background-color == none {
    rgb(self.colors.primary)
  } else {
    background-color
  }
  let args = (:)
  if background-color != none {
    args.fill = background-color
  }
  if background-img != none {
    args.background = {
      set image(fit: "stretch", width: 100%, height: 100%)
      background-img
    }
  }
  // Allow disabling the footer via store flag
  if not self.store.show-footer {
    args.footer = none
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: 1em, ..args),
  )
  set text(fill: self.colors.neutral-lightest, weight: "bold", size: 2em)
  touying-slide(self: self, align(horizon, body))
})


// Create a slide where the provided content blocks are displayed in a grid and coloured in a checkerboard pattern without further decoration. You can configure the grid using the rows and `columns` keyword arguments (both default to none). It is determined in the following way:
///
/// - If `columns` is an integer, create that many columns of width `1fr`.
/// - If `columns` is `none`, create as many columns of width `1fr` as there are content blocks.
/// - Otherwise assume that `columns` is an array of widths already, use that.
/// - If `rows` is an integer, create that many rows of height `1fr`.
/// - If `rows` is `none`, create that many rows of height `1fr` as are needed given the number of co/ -ntent blocks and columns.
/// - Otherwise assume that `rows` is an array of heights already, use that.
/// - Check that there are enough rows and columns to fit in all the content blocks.
///
/// That means that `#matrix-slide[...][...]` stacks horizontally and `#matrix-slide(columns: 1)[...][...]` stacks vertically.
/// 
#let matrix-slide(columns: none, rows: none, ..bodies) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em, footer: if not self.store.show-footer { none } else { auto }),
  )
  touying-slide(self: self, composer: components.checkerboard.with(columns: columns, rows: rows), ..bodies)
})


/// Touying university theme.
///
/// Example:
///
/// ```typst
/// #show: university-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// - `aspect-ratio` is the aspect ratio of the slides. Default is `16-9`.
///
/// - `progress-bar` is whether to show the progress bar. Default is `true`.
///
/// - `header` is the header of the slides. Default is `utils.display-current-heading(level: 2)`.
///
/// - `header-right` is the right part of the header. Default is `self.info.logo`.
///
/// - `footer-columns` is the columns of the footer. Default is `(25%, 1fr, 25%)`.
///
/// - `footer-a` is the left part of the footer. Default is `self.info.author`.
///
/// - `footer-b` is the middle part of the footer. Default is `self.info.short-title` or `self.info.title`.
///
/// - `footer-c` is the right part of the footer. Default is `self => h(1fr) + utils.display-info-date(self) + h(1fr) + context utils.slide-counter.display() + " / " + utils.last-slide-number + h(1fr)`.
///
/// ----------------------------------------
///
/// The default colors:
///
/// ```typ
/// config-colors(
///   primary: rgb("#04364A"),
///   secondary: rgb("#176B87"),
///   tertiary: rgb("#448C95"),
///   neutral-lightest: rgb("#ffffff"),
///   neutral-darkest: rgb("#000000"),
/// )
/// ```
#let university-theme(
  aspect-ratio: "16-9",
  progress-bar: true,
  header-bottom-gap: 0.8em,
  show-footer: true,
  base-text-size: 21pt,
  header: utils.display-current-heading(level: 2),
  header-right: self => utils.display-current-heading(level: 1) + h(.3em) + self.info.logo,
  footer-columns: (25%, 1fr, 25%),
  footer-a: self => self.info.author,
  footer-b: self => {
    let title = if self.info.short-title == auto { self.info.title } else { self.info.short-title }
    if "lecture-number" in self.info {
      text([Lecture #self.info.lecture-number · #utils.display-current-heading(level: 1)]) 
    } else {
      title
    }
  },
  footer-c: self => {
    h(1fr)
    utils.display-info-date(self)
    h(1fr)
    context utils.slide-counter.display() + " / " + utils.last-slide-number
    h(1fr)
  },
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 3.5em, bottom: 1em, x: 4em),
      header-ascent: 0em,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        // Global base text size (slightly smaller by default)
        set text(fill: self.colors.neutral-darkest, size: self.store.base-text-size)
        show heading: set text(fill: self.colors.primary)
        body
      },
      alert: utils.alert-with-primary-color, // this redefines stronger
      // Use state-driven cover behavior (soft vs hard pause)
      cover: cover-it,
    ),
    config-colors(
      primary: green.darken(60%),
      secondary: green.darken(40%),
      tertiary: green.darken(30%),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: text-color,
      contrast: contrast-color,
    ),
    config-store(
      progress-bar: progress-bar,
      header-bottom-gap: header-bottom-gap,
      show-footer: show-footer,
      base-text-size: base-text-size,
      header: header,
      header-right: header-right,
      footer-columns: footer-columns,
      footer-a: footer-a,
      footer-b: footer-b,
      footer-c: footer-c,
    ),
    ..args,
  )
  
  body
}
