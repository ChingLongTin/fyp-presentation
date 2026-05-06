"""
Final FYP video — Dynamic Staging in MLscript.

Render each segment separately:
    manim -pql final_video.py TitleCard
    manim -pql final_video.py Motivation
    manim -pql final_video.py MSPApproach
    manim -pql final_video.py OurApproach
    manim -pql final_video.py PowExample
    manim -pql final_video.py Novelty
    manim -pql final_video.py Benchmarks
    manim -pql final_video.py Closing

Or render and concatenate them all in one go:
    manim -pql final_video.py FinalVideo

The voice-over script in script.md is timed against this animation.
"""

from manim import *
from manim import Text as _BaseText


# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------


# Manim's `Text` (Pango-backed) rounds glyph metrics at the rasterisation size,
# so at small font_size values (≲ 30) characters appear weirdly kerned
# ("ex" sticking together, etc.). Workaround: always render at a large base
# size where Pango has enough sub-pixel precision, then scale down to the
# requested visual size. This keeps the public API unchanged.
_TEXT_BASE_FONT_SIZE = 96


def Text(text, font_size=24, **kwargs):  # noqa: N802 — intentional override
    base = _BaseText(text, font_size=_TEXT_BASE_FONT_SIZE, **kwargs)
    return base.scale(font_size / _TEXT_BASE_FONT_SIZE)


def mls(code, font_size=None):
    """Render a snippet of MLscript code (re-used from main.py)."""
    kwargs = dict(
        code_string=code,
        add_line_numbers=False,
        language="javascript",
        tab_width=2,
        formatter_style="emacs",
        paragraph_config={"line_spacing": 1},
    )
    if font_size is not None:
        kwargs["paragraph_config"]["font_size"] = font_size
    return Code(**kwargs)


def section_title(text):
    return Text(text, weight=BOLD, font_size=42).to_edge(UP)


# -----------------------------------------------------------------------------
# 1. Title card
# -----------------------------------------------------------------------------


class TitleCard(Scene):
    def construct(self):
        title = Text("Dynamic Staging", weight=BOLD, font_size=64)
        sub = Text(
            "High-level code, low-level performance, by one keyword.",
            font_size=28,
            slant=ITALIC,
            color=GREY_B,
        )
        authors = Text(
            "CHING Long Tin · YEUNG Sin Chun     |     HKUST FYP, 2026",
            font_size=22,
            color=GREY_C,
        )
        sub.next_to(title, DOWN, buff=0.4)
        authors.next_to(sub, DOWN, buff=0.6)
        group = VGroup(title, sub, authors).move_to(ORIGIN)

        self.play(FadeIn(title, shift=UP * 0.3), run_time=0.8)
        self.play(FadeIn(sub), FadeIn(authors), run_time=0.8)
        self.wait(3.5)
        self.play(FadeOut(group), run_time=0.5)


# -----------------------------------------------------------------------------
# 2. Motivation — dot product
# -----------------------------------------------------------------------------


class Motivation(Scene):
    def construct(self):
        head = section_title("Abstraction vs. Performance")

        # Tradeoff message at the top.
        tradeoff = VGroup(
            Text(
                "Programmers want abstraction & generality...",
                font_size=26,
                color=GREY_B,
            ),
            Text(
                "but pay for it at runtime.",
                font_size=26,
                color=RED_C,
            ),
        ).arrange(DOWN, buff=0.15)
        tradeoff.next_to(head, DOWN, buff=0.3)

        general = """fun dot(xs, ys, i) =
  if xs.length == i then 0
  else xs.(i) * ys.(i) + dot(xs, ys, i + 1)
fun dotWith3(v) = dot([1, 0, 2], v, 0)"""

        residual = """fun dotWith3(v) =
  v.(0) + 2 * v.(2)"""

        c1 = mls(general).scale(0.55)
        c3 = mls(residual).scale(0.55)

        l1 = Text("What we write", font_size=20, color=GREY_B)
        l3 = Text("What Dynamic Staging produces", font_size=20, color=GREEN_D)

        col1 = VGroup(l1, c1).arrange(DOWN, buff=0.2)
        col3 = VGroup(l3, c3).arrange(DOWN, buff=0.2)

        # Layout: source on left, residual on right, arrow between.
        # Align tops so the two labels sit on the same baseline.
        cols = VGroup(col1, col3).arrange(RIGHT, buff=2.2, aligned_edge=UP)
        cols.next_to(tradeoff, DOWN, buff=0.6)

        # Horizontal arrow that points to the centre of the left border of
        # the *right* code snippet (c3).  Both endpoints share c3's y so the
        # arrow stays perfectly horizontal even though c1 is taller.
        arrow_y = c3.get_center()[1]
        arrow = Arrow(
            np.array([c1.get_right()[0], arrow_y, 0]),
            np.array([c3.get_left()[0], arrow_y, 0]),
            buff=0.0,
            color=YELLOW,
            stroke_width=5,
        )
        arrow_lbl = Text("Dynamic Staging", font_size=18, color=YELLOW_E).next_to(
            arrow, UP, buff=0.1
        )

        self.play(FadeIn(head))
        self.play(FadeIn(tradeoff[0]))
        self.play(FadeIn(tradeoff[1]))
        self.wait(0.6)
        self.play(FadeIn(l1), Write(c1), run_time=1.2)

        # Highlight the wasted parts of the source.
        wasted = SurroundingRectangle(
            VGroup(c1.code_lines[1], c1.code_lines[2]),
            color=RED,
            buff=0.05,
        )
        wasted_lbl = Text(
            "loop, recursion, ×0 — all dictated by [1, 0, 2]",
            font_size=18,
            color=RED_C,
        ).next_to(c1, DOWN, buff=0.25)
        self.play(Create(wasted), FadeIn(wasted_lbl))
        self.wait(2.0)

        self.play(FadeOut(wasted), FadeOut(wasted_lbl))
        self.play(GrowArrow(arrow), FadeIn(arrow_lbl))
        self.play(FadeIn(l3), Write(c3), run_time=1.0)

        # Goal callout placed directly below the pipeline so the reader's
        # eye flows from the residual code straight into the takeaway.
        bottom = Text(
            "Goal: let the programmer maintain the abstract version, and have"
            " the compiler automatically create an efficient implementation.",
            font_size=22,
            color=GREEN_D,
        )
        bottom.next_to(cols, DOWN, buff=0.55)
        self.play(FadeIn(bottom))
        self.wait(4.0)
        self.play(
            FadeOut(
                VGroup(
                    head,
                    tradeoff,
                    l1,
                    c1,
                    l3,
                    c3,
                    arrow,
                    arrow_lbl,
                    bottom,
                )
            )
        )


# -----------------------------------------------------------------------------
# 3. Existing approach — Multi-Stage Programming
# -----------------------------------------------------------------------------


class MSPApproach(Scene):
    """Modeled after `MSPAnnotation` in main.py: just morph plain `pow` into
    the MSP-annotated version and highlight the annotation symbols. The title
    stays centered at the top; no extra columns are added."""

    def construct(self):
        head = section_title("Existing approach: Multi-Stage Programming")
        cite = Text("[Taha, 2004]", font_size=20, color=GREY_C).next_to(
            head, DOWN, buff=0.1
        )

        plain_src = """
module M with
  fun pow(n, x) = if n is
    0 then 1
    else x * pow(n - 1, x)"""

        annotated_src = """
module M with
  fun pow(n, x) = if n is
    0 then .<1>.
    else .<.~x * .~(pow(n-1, x))>."""

        before = mls(plain_src).scale(0.85).move_to(ORIGIN).shift(DOWN * 0.2)
        after = mls(annotated_src).scale(0.85).move_to(before, aligned_edge=ORIGIN)

        self.play(FadeIn(head), FadeIn(cite))
        self.play(Write(before))
        self.wait(0.8)
        self.play(FadeTransform(before, after))

        # Highlight the MSP annotations (same regions as in main.MSPAnnotation).
        lines = after.code_lines
        relevant = [
            lines[2][5:7],          # .<
            lines[2][-2:],          # >.
            lines[3][4:4 + 4],      # .<.~
            lines[3][10:13],        # .~(
            lines[3][-3:],          # )>.
        ]
        annot_highlights = VGroup(
            *[
                SurroundingRectangle(x, buff=0)
                .set_fill(YELLOW)
                .set_opacity(0)
                for x in relevant
            ]
        )
        self.add(annot_highlights)
        self.play(annot_highlights.animate.set_opacity(0.3))
        self.wait(3.5)

        self.play(FadeOut(VGroup(head, cite, after, annot_highlights)))


# -----------------------------------------------------------------------------
# 4. Our approach — one keyword
# -----------------------------------------------------------------------------


class OurApproach(Scene):
    def construct(self):
        # Title: "staged turns a module into a code generator".  Render
        # `staged` as bold-italic monospace so it reads as a keyword without
        # the visual weight of a full code block.
        head = Text(
            "staged turns a module into a code generator",
            weight=BOLD,
            font_size=42,
        ).to_edge(UP)

        # =====================================================================
        # Phase 1 — plain module: full-width pipeline, ends in a value
        # =====================================================================

        plain_src = """module M with
  fun pow(n, x) = if n is
    0 then 1
    else x * pow(n - 1, x)
  fun cube(x) = pow(x, 3)
M.cube(5)"""

        c1 = mls(plain_src).scale(0.7)
        c1_lbl = Text("source program", font_size=20, color=GREY_B)
        src_grp = VGroup(c1_lbl, c1).arrange(DOWN, buff=0.2)

        # Box drawn around a centred value to make labels easy to centre too.
        value1_text = Text("125", font="Menlo", font_size=44, color=GREEN_D)
        value1 = VGroup(value1_text)
        v1_lbl = Text("Result", font_size=20, color=GREY_B)
        v1_grp = VGroup(v1_lbl, value1).arrange(DOWN, buff=0.2, aligned_edge=ORIGIN)

        # Centre everything horizontally as a single pipeline.
        arrow1_len = 2.0  # extra-long arrow so the label is never squished
        spacer = Rectangle(width=arrow1_len, height=0.001).set_opacity(0)
        pipeline1 = VGroup(src_grp, spacer, v1_grp).arrange(RIGHT, buff=0.4)
        pipeline1.move_to(ORIGIN).shift(DOWN * 0.2)

        arrow1 = Arrow(
            spacer.get_left(),
            spacer.get_right(),
            buff=0.0,
            color=YELLOW_E,
            stroke_width=4,
            max_tip_length_to_length_ratio=0.12,
        )
        arrow1_lbl = Text("execute", font_size=20, color=YELLOW_E)
        arrow1_lbl.move_to(arrow1.get_center() + UP * 0.32)

        normal_caption = Text(
            "Normal module: one stage. The runtime does all the work.",
            font_size=22,
            color=GREY_B,
        )
        normal_caption.next_to(pipeline1, DOWN, buff=0.6)

        self.play(FadeIn(head))
        self.play(FadeIn(c1_lbl), Write(c1))
        self.play(GrowArrow(arrow1), FadeIn(arrow1_lbl))
        self.play(FadeIn(v1_lbl), FadeIn(value1, shift=RIGHT * 0.2))
        self.play(FadeIn(normal_caption))
        self.wait(2.5)

        # =====================================================================
        # Phase 2 — staged: residual module is much longer, so we re-layout
        # the entire pipeline centred horizontally:
        #   [src]  --stage 1: execute-->  [residual M]  --stage 2: execute-->  125
        # =====================================================================

        # Add the keyword.
        staged_src = """staged module M with
  fun pow(n, x) = if n is
    0 then 1
    else x * pow(n - 1, x)
  fun cube(x) = pow(x, 3)
M.cube(5)"""
        c2 = mls(staged_src).scale(0.7)
        c2.move_to(c1, aligned_edge=ORIGIN)

        self.play(FadeOut(normal_caption))
        self.play(FadeTransform(c1, c2))

        # Highlight the new keyword. Compute width based on the rendered code.
        kw_line = c2.code_lines[0]
        kw_width = kw_line.width * (len("staged") / len("staged module M with"))
        kw_box = Rectangle(
            width=kw_width + 0.1,
            height=kw_line.height + 0.1,
            stroke_color=YELLOW,
            stroke_width=3,
            fill_color=YELLOW,
            fill_opacity=0.3,
        )
        kw_box.move_to(
            np.array([kw_line.get_left()[0] + kw_width / 2, kw_line.get_center()[1], 0])
        )
        self.play(Create(kw_box), Flash(kw_box, color=YELLOW, line_length=0.3))

        # ----- Build the residual module (named M, with pow0..pow3, cube). ----
        residual_src = """module M with
  fun pow0(x) = 1
  fun pow1(x) = x * pow0(x)
  fun pow2(x) = x * pow1(x)
  fun pow3(x) = x * pow2(x)
  fun cube(x) = pow3(x)"""
        residual = mls(residual_src).scale(0.5)
        residual_lbl = Text("residual module", font_size=16, color=YELLOW_E)
        res_grp = VGroup(residual_lbl, residual).arrange(DOWN, buff=0.15)

        value2_text = Text("125", font="Menlo", font_size=36, color=GREEN_D)
        value2_lbl = Text("Result", font_size=16, color=YELLOW_E)
        value2_grp = VGroup(value2_lbl, value2_text).arrange(DOWN, buff=0.15, aligned_edge=ORIGIN)

        # ----- Compute the target centred layout. -----------------------------
        # We use invisible placeholders for the source (which already exists on
        # screen) and for the two arrow zones. arrange() then positions res_grp
        # and value2_grp at their final locations, and we move/transform the
        # other elements to match.
        src_target_scale = 0.85
        src_grp_p2 = VGroup(c1_lbl, c2, kw_box)
        src_ph = Rectangle(
            width=src_grp_p2.width * src_target_scale,
            height=src_grp_p2.height * src_target_scale,
        ).set_opacity(0)
        arr1_zone = Rectangle(width=1.5, height=0.01).set_opacity(0)
        arr2_zone = Rectangle(width=1.5, height=0.01).set_opacity(0)

        target_layout = VGroup(
            src_ph, arr1_zone, res_grp, arr2_zone, value2_grp
        ).arrange(RIGHT, buff=0.3)
        target_layout.move_to(ORIGIN).shift(DOWN * 0.15)

        # Stage-1 arrow & label that match the new layout.
        arrow1_target = Arrow(
            arr1_zone.get_left(),
            arr1_zone.get_right(),
            buff=0.0,
            color=YELLOW_E,
            stroke_width=4,
            max_tip_length_to_length_ratio=0.12,
        )
        arrow1_lbl2 = Text("stage 1", font_size=18, color=YELLOW_E)
        arrow1_lbl2.move_to(arrow1_target.get_center() + UP * 0.28)

        # Move the source group to its new (smaller, leftmost) position, and
        # simultaneously morph the stage-1 arrow + label.
        self.play(
            FadeOut(v1_grp),
            src_grp_p2.animate.scale(src_target_scale).move_to(src_ph),
            Transform(arrow1, arrow1_target),
            Transform(arrow1_lbl, arrow1_lbl2),
        )
        self.play(FadeIn(res_grp))
        self.wait(1.0)

        # ----- Stage-2 arrow + final value (rightmost). -----------------------
        arrow2 = Arrow(
            arr2_zone.get_left(),
            arr2_zone.get_right(),
            buff=0.0,
            color=YELLOW_E,
            stroke_width=4,
            max_tip_length_to_length_ratio=0.12,
        )
        arrow2_lbl = Text("stage 2", font_size=18, color=YELLOW_E)
        arrow2_lbl.move_to(arrow2.get_center() + UP * 0.28)

        self.play(GrowArrow(arrow2), FadeIn(arrow2_lbl))
        self.play(FadeIn(value2_grp, shift=RIGHT * 0.2))

        # Two-stage caption.
        meta_caption = Text(
            "Two stages: stage 1 emits an optimised residual module that the user runs in stage 2.",
            font_size=20,
            color=YELLOW_E,
        )
        meta_caption.next_to(target_layout, DOWN, buff=0.6)
        self.play(FadeIn(meta_caption))
        self.wait(4.5)

        self.play(
            FadeOut(
                VGroup(
                    head,
                    src_grp_p2,
                    arrow1,
                    arrow1_lbl,
                    res_grp,
                    arrow2,
                    arrow2_lbl,
                    value2_grp,
                    meta_caption,
                )
            )
        )


# -----------------------------------------------------------------------------
# 5. Worked example — pow
# -----------------------------------------------------------------------------


class PowExample(Scene):
    def construct(self):
        head = section_title("Stage 1: peeling the recursion")
        self.play(FadeIn(head))

        # ---- Status banner: which call we are currently specialising. ----
        status_label = Text("Now specializing:", font_size=18, color=GREY_B)
        status_call = Text("(idle)", font="Menlo", font_size=20, color=YELLOW_E)
        status = VGroup(status_label, status_call).arrange(RIGHT, buff=0.2, aligned_edge=DOWN)
        status.next_to(head, DOWN, buff=0.2)
        self.play(FadeIn(status))

        # ---- Source code on the left. ----
        body_src = """staged module M with
  fun pow(n, x) = if n is
    0 then 1
    else x * pow(n - 1, x)
  fun cube(x) = pow(x, 3)"""
        code = mls(body_src).scale(0.55)
        code.next_to(status, DOWN, buff=0.4).to_edge(LEFT, buff=0.6)
        self.play(Write(code), run_time=1.4)

        # ---- Single-concept legend: only Dyn. ----
        legend = Text(
            "Dyn = a value whose actual contents are unknown until runtime.",
            font_size=18,
            color=GREY_B,
        ).next_to(code, DOWN, buff=0.45).align_to(code, LEFT)
        self.play(FadeIn(legend))
        self.wait(1.6)

        # =================================================================
        # Build two side-by-side tables on the right: Specialized Functions
        # and Shape Context.  They share a common left edge so they line up.
        # =================================================================

        ROW_H = 0.42

        # --- Specialized Functions table ---
        SF_COL_LEFT = [0.0, 1.45]
        sf_hdr = (
            Text("Function", font_size=16, weight=BOLD, color=YELLOW_E),
            Text("Specialized body", font_size=16, weight=BOLD, color=YELLOW_E),
        )
        sf_data = [
            ("pow3(x)", "x * pow2(x)"),
            ("pow2(x)", "x * pow1(x)"),
            ("pow1(x)", "x * pow0(x)"),
            ("pow0(x)", "1"),
        ]
        sf_rows = [
            (
                Text(fn, font="Menlo", font_size=15, color=BLUE_C),
                Text(body, font="Menlo", font_size=15, color=GREEN_D),
            )
            for fn, body in sf_data
        ]

        def place_row(cells, cols, y):
            for cell, lx in zip(cells, cols):
                cell.move_to(np.array([lx + cell.width / 2, y, 0]))

        place_row(sf_hdr, SF_COL_LEFT, 0.0)
        for i, row in enumerate(sf_rows):
            place_row(row, SF_COL_LEFT, -(i + 1) * ROW_H - 0.12)

        sf_cells = VGroup(*sf_hdr, *(c for r in sf_rows for c in r))
        sf_frame = SurroundingRectangle(
            sf_cells, color=YELLOW_E, buff=0.28, corner_radius=0.1
        )
        sf_div_y = sf_hdr[0].get_bottom()[1] - 0.08
        sf_div = Line(
            np.array([sf_frame.get_left()[0] + 0.08, sf_div_y, 0]),
            np.array([sf_frame.get_right()[0] - 0.08, sf_div_y, 0]),
            color=YELLOW_E, stroke_width=1.5,
        )
        sf_title = Text(
            "Specialized Functions", font_size=18, weight=BOLD, color=YELLOW_E,
        ).next_to(sf_frame, UP, buff=0.12).align_to(sf_frame, LEFT).shift(RIGHT * 0.1)
        sf_grp = VGroup(sf_title, sf_frame, sf_div, *sf_hdr, *(c for r in sf_rows for c in r))

        # --- Shape Context table ---
        SC_COL_LEFT = [0.0, 1.1]
        sc_hdr = (
            Text("Variable", font_size=16, weight=BOLD, color=BLUE_C),
            Text("Shape", font_size=16, weight=BOLD, color=BLUE_C),
        )
        # Pre-size the table for two binding rows so the frame is tall enough.
        ph_rows = []
        for j in range(2):
            v = Text("recurse", font="Menlo", font_size=15, color=GREY_B)
            s = Text("Lit 3", font="Menlo", font_size=15, color=GREY_B)
            place_row((v, s), SC_COL_LEFT, -(j + 1) * ROW_H - 0.12)
            ph_rows.extend([v, s])
        place_row(sc_hdr, SC_COL_LEFT, 0.0)
        sc_cells = VGroup(*sc_hdr, *ph_rows)
        sc_frame = SurroundingRectangle(
            sc_cells, color=BLUE_C, buff=0.28, corner_radius=0.1
        )
        sc_div_y = sc_hdr[0].get_bottom()[1] - 0.08
        sc_div = Line(
            np.array([sc_frame.get_left()[0] + 0.08, sc_div_y, 0]),
            np.array([sc_frame.get_right()[0] - 0.08, sc_div_y, 0]),
            color=BLUE_C, stroke_width=1.5,
        )
        sc_title = Text(
            "Shape Context", font_size=18, weight=BOLD, color=BLUE_C,
        ).next_to(sc_frame, UP, buff=0.12).align_to(sc_frame, LEFT).shift(RIGHT * 0.1)
        # Don't render the placeholder rows.
        for ph in ph_rows:
            sc_cells.remove(ph)
        # Keep only the headers + frame visible at the start; rows fill in
        # dynamically.
        sc_grp = VGroup(sc_title, sc_frame, sc_div, *sc_hdr)

        # --- Place both tables on the right, top edge aligned. ---
        right_panel = VGroup(sf_grp, sc_grp).arrange(
            DOWN, aligned_edge=LEFT, buff=0.55,
        )
        right_panel.scale(0.85)
        right_panel.to_edge(RIGHT, buff=0.4).align_to(code, UP)

        # Hide the SF rows initially.
        sf_rows_grp = VGroup(*(c for r in sf_rows for c in r))
        sf_rows_grp.set_opacity(0)

        self.play(
            Create(sf_frame),
            FadeIn(VGroup(sf_title, sf_div, *sf_hdr)),
            Create(sc_frame),
            FadeIn(VGroup(sc_title, sc_div, *sc_hdr)),
        )
        self.wait(0.6)

        # =================================================================
        # Step 1: cube initiates the call pow(x, 3).
        # =================================================================
        narr1 = Text(
            "cube(x) calls pow(x, 3) — that's where stage 1 begins.",
            font_size=18, color=GREY_B,
        ).next_to(legend, DOWN, buff=0.4).align_to(code, LEFT)
        cube_box = SurroundingRectangle(code.code_lines[4], color=YELLOW, buff=0.04)
        self.play(Create(cube_box), FadeIn(narr1))
        self.wait(1.5)

        # Animated "zoom in" on the pow function: swap the full module for a
        # larger snippet that only shows pow's body.  We keep `code` as the
        # off-screen reference for `code_lines` indexing in later steps —
        # but redraw the visible code at a bigger size in the same slot.
        pow_only_src = """fun pow(n, x) = if n is
  0 then 1
  else x * pow(n - 1, x)"""
        big_code = mls(pow_only_src).scale(0.75)
        big_code.move_to(code.get_center()).align_to(code, LEFT)

        self.play(
            FadeOut(cube_box),
            FadeOut(code),
            FadeIn(big_code),
            run_time=1.0,
        )
        # From here on, use big_code instead of code for highlights.
        code = big_code
        self.wait(0.6)

        # =================================================================
        # Helper: update the status banner & shape-context rows in sync.
        # =================================================================
        sc_rows_visible = []  # list of VGroup(var, shape)

        def set_status(call_str):
            new = Text(call_str, font="Menlo", font_size=20, color=YELLOW_E)
            new.move_to(status_call.get_center()).align_to(status_call, LEFT)
            self.play(FadeTransform(status_call, new), run_time=0.5)
            return new

        def set_shape_ctx(bindings):
            """Replace the shape context with the given list of (var, shape) pairs."""
            old = VGroup(*sc_rows_visible) if sc_rows_visible else None
            sc_rows_visible.clear()
            new_rows = []
            for i, (v, s) in enumerate(bindings):
                vt = Text(v, font="Menlo", font_size=15, color=GREY_B)
                st = Text(s, font="Menlo", font_size=15, color=GREEN_D)
                place_row((vt, st), SC_COL_LEFT, -(i + 1) * ROW_H - 0.12)
                row = VGroup(vt, st)
                row.scale(0.85)  # match panel scale
                # Place it inside sc_grp's coordinate frame.
                # Compute target position: directly under header by row index.
                target_y = (
                    sc_hdr[0].get_bottom()[1]
                    - 0.18
                    - (i + 0.5) * (sc_hdr[0].height + 0.18)
                )
                row.move_to(np.array([
                    sc_hdr[0].get_left()[0] + (vt.width + st.width) / 2 + 0.3,
                    target_y, 0,
                ]))
                # Re-place individual cells under their header columns.
                vt.align_to(sc_hdr[0], LEFT)
                st.align_to(sc_hdr[1], LEFT)
                vt.set_y(target_y)
                st.set_y(target_y)
                new_rows.append(row)
                sc_rows_visible.append(row)
            anims = []
            if old is not None:
                anims.append(FadeOut(old, run_time=0.3))
            anims.extend(FadeIn(r, shift=RIGHT * 0.1) for r in new_rows)
            self.play(*anims, run_time=0.6)

        # =================================================================
        # Step 2: specialise pow(x, 3).
        # =================================================================
        status_call = set_status("pow(x, 3)")
        narr2 = Text(
            "pow(x, 3): the second argument is the literal 3, the first is Dyn.",
            font_size=18, color=GREY_B,
        ).next_to(legend, DOWN, buff=0.4).align_to(code, LEFT)
        self.play(FadeTransform(narr1, narr2))
        set_shape_ctx([("n", "Lit 3"), ("x", "Dyn")])
        self.wait(1.5)

        # =================================================================
        # Step 3: walk through the four specialisations.
        # Each iteration: highlight dead/live branch, beam result into SF table,
        # update shape context with the new n.
        # =================================================================
        narrations = [
            ("pow(x, 3)",
             "n = Lit 3 ≠ 0  →  the 'then 1' branch is dead.  Emit pow3(x) = x * pow2(x)."),
            ("pow(x, 2)",
             "Recurse with n = Lit 2.  Same shape, same peel.  Emit pow2(x) = x * pow1(x)."),
            ("pow(x, 1)",
             "Recurse with n = Lit 1.  Same peel.  Emit pow1(x) = x * pow0(x)."),
            ("pow(x, 0)",
             "Recurse with n = Lit 0.  Now the 'else' branch is dead.  Emit pow0(x) = 1."),
        ]
        prev_narr = narr2
        for i in range(4):
            k = 3 - i
            call_str, narr_str = narrations[i]
            if i > 0:  # already set status for k=3 above
                status_call = set_status(call_str)
                set_shape_ctx([("n", f"Lit {k}"), ("x", "Dyn")])

            n_text = Text(narr_str, font_size=18, color=GREY_B)
            n_text.next_to(legend, DOWN, buff=0.4).align_to(code, LEFT)

            if k > 0:
                dead_line = code.code_lines[1]   # "  0 then 1"
                live_line = code.code_lines[2]   # "  else x * pow(n - 1, x)"
            else:
                dead_line = code.code_lines[2]
                live_line = code.code_lines[1]

            dead_box = SurroundingRectangle(dead_line, color=RED, buff=0.04)
            cross = Cross(dead_box, color=RED, stroke_width=4)
            live_box = SurroundingRectangle(live_line, color=GREEN_D, buff=0.04)

            self.play(FadeTransform(prev_narr, n_text))
            self.play(Create(dead_box), Create(cross), run_time=0.7)
            self.wait(0.5)
            self.play(Create(live_box), run_time=0.5)

            row_cells = VGroup(*sf_rows[i])
            beam = Arrow(
                live_box.get_right(),
                row_cells.get_left() + LEFT * 0.05,
                color=YELLOW_E,
                stroke_width=2.5,
                buff=0.08,
                max_tip_length_to_length_ratio=0.05,
            )
            self.play(GrowArrow(beam), run_time=0.5)
            row_cells.set_opacity(1)
            self.play(FadeIn(row_cells, shift=RIGHT * 0.15), run_time=0.6)
            self.wait(0.8)
            self.play(
                FadeOut(beam),
                FadeOut(dead_box),
                FadeOut(cross),
                FadeOut(live_box),
                run_time=0.4,
            )
            prev_narr = n_text

        # =================================================================
        # Step 4: strip away the helpers — only cube survives.
        # =================================================================
        status_call = set_status("strip pow0..pow3")
        narr_inline = Text(
            "pow0..pow2 only existed to feed pow3.  After staging they are stripped away.",
            font_size=18, color=GREEN_D,
        ).next_to(legend, DOWN, buff=0.4).align_to(code, LEFT)
        self.play(FadeTransform(prev_narr, narr_inline))

        # Fade out pow0..pow2 rows; replace pow3's row with a single
        # `cube(x) = x * x * x` line that takes the spot of the top row.
        helpers = VGroup(
            sf_rows[1][0], sf_rows[1][1],
            sf_rows[2][0], sf_rows[2][1],
            sf_rows[3][0], sf_rows[3][1],
        )
        self.play(FadeOut(helpers), run_time=0.8)

        cube_fn = Text("cube(x)", font="Menlo", font_size=15, color=BLUE_C)
        cube_body = Text("x * x * x", font="Menlo", font_size=15, color=GREEN_D)
        cube_fn.scale(0.85)
        cube_body.scale(0.85)
        cube_fn.move_to(sf_rows[0][0].get_center()).align_to(sf_rows[0][0], LEFT)
        cube_body.move_to(sf_rows[0][1].get_center()).align_to(sf_rows[0][1], LEFT)
        self.play(
            FadeTransform(sf_rows[0][0], cube_fn),
            FadeTransform(sf_rows[0][1], cube_body),
        )
        self.wait(3.0)

        self.play(
            FadeOut(VGroup(
                head, status, code, legend, sf_grp, sc_grp,
                *sc_rows_visible, narr_inline, cube_fn, cube_body,
            )),
        )


# -----------------------------------------------------------------------------
# 5b. Shape propagation — the intuitive engine behind staging
# -----------------------------------------------------------------------------


class ShapeProp(Scene):
    """Intuitive walk-through of how the compiler tracks 'shapes' and uses
    them to peel away dead branches at stage 1, ending with a pointer to the
    web demo."""

    def construct(self):
        def shape_pill(label, color, font_size=22):
            t = Text(label, font_size=font_size, color=BLACK)
            box = SurroundingRectangle(
                t, buff=0.12, corner_radius=0.12, color=color
            ).set_fill(color, opacity=0.9)
            return VGroup(box, t)

        head = section_title("How does the compiler know what to peel?")
        self.play(FadeIn(head))

        # =====================================================================
        # Part 1 — what is a "shape"? A tiny static fact about a value.
        # =====================================================================
        sub1 = Text(
            "Idea: tag every value with a  shape  — a tiny static fact.",
            font_size=24,
            color=GREY_B,
        ).next_to(head, DOWN, buff=0.2)
        self.play(FadeIn(sub1))

        examples = VGroup(
            VGroup(Text("3", font_size=28), Text("→", font_size=28),
                   shape_pill("Lit 3", GREEN_C)),
            VGroup(Text('"hi"', font_size=28), Text("→", font_size=28),
                   shape_pill('Lit "hi"', GREEN_C)),
            VGroup(Text("x  (parameter)", font_size=28), Text("→", font_size=28),
                   shape_pill("Dyn", GREY)),
            VGroup(Text("new B1(2)", font_size=28), Text("→", font_size=28),
                   shape_pill("B1(Lit 2)", BLUE_C)),
            VGroup(Text("if b then B1(2) else B2(3)", font_size=28),
                   Text("→", font_size=28),
                   shape_pill("B1(Lit 2) ∪ B2(Lit 3)", PURPLE_B)),
        )
        for row in examples:
            row.arrange(RIGHT, buff=0.4, aligned_edge=DOWN)
        examples.arrange(DOWN, aligned_edge=LEFT, buff=0.3).next_to(
            sub1, DOWN, buff=0.5
        ).shift(LEFT * 0.4)

        legend = VGroup(
            VGroup(shape_pill("•", GREEN_C, font_size=18),
                   Text("known statically", font_size=18, color=GREEN_D)),
            VGroup(shape_pill("•", GREY, font_size=18),
                   Text("unknown until runtime", font_size=18, color=GREY_B)),
            VGroup(shape_pill("•", PURPLE_B, font_size=18),
                   Text("disjunction (our novelty)", font_size=18, color=PURPLE_B)),
        )
        for row in legend:
            row.arrange(RIGHT, buff=0.2)
        legend.arrange(DOWN, aligned_edge=LEFT, buff=0.18)
        legend.to_edge(RIGHT, buff=0.4).align_to(examples, UP)

        for row in examples:
            self.play(FadeIn(row[0]), run_time=0.2)
            self.play(FadeIn(row[1]), FadeIn(row[2], shift=RIGHT * 0.15), run_time=0.3)
        self.play(FadeIn(legend))
        self.wait(2.5)
        self.play(FadeOut(VGroup(examples, legend, sub1)))

        # =====================================================================
        # Part 2 — shapes propagate. Walk through cube(x) = pow(x, 3).
        # =====================================================================
        sub2 = Text(
            "Shapes propagate through calls — and prune dead branches.",
            font_size=24,
            color=GREY_B,
        ).next_to(head, DOWN, buff=0.2)
        self.play(FadeIn(sub2))

        code = mls(
            """fun cube(x) = pow(x, 3)

fun pow(n, x) = if n is
  0 then 1
  else x * pow(n - 1, x)"""
        ).scale(0.85)
        code.next_to(sub2, DOWN, buff=0.4).to_edge(LEFT, buff=0.7)
        self.play(Write(code))

        # Side panel that shows the running shape environment.
        ctx_title = Text("shape context", font_size=18, weight=BOLD, color=YELLOW_E)
        ctx_lines = VGroup()  # filled in dynamically
        # Reserve space for the widest line we will eventually add so the
        # frame is sized correctly up-front.
        widest = Text(
            "pow:    n = Lit 3,  x = Lit 5",
            font="Menlo", font_size=15, color=GREY_B,
        )
        ctx_inner = VGroup(ctx_title, widest).arrange(
            DOWN, aligned_edge=LEFT, buff=0.18
        )
        ctx_frame = SurroundingRectangle(
            ctx_inner, color=YELLOW_E, buff=0.25, corner_radius=0.1
        )
        ctx_frame.stretch_to_fit_height(4.2).align_to(ctx_inner, UP).shift(UP * 0.1)
        # Don't actually render the placeholder.
        ctx_inner.remove(widest)
        ctx_grp = VGroup(ctx_frame, ctx_inner)
        ctx_grp.to_edge(RIGHT, buff=0.5).align_to(code, UP)
        ctx_lines.next_to(ctx_title, DOWN, aligned_edge=LEFT, buff=0.18)

        self.play(Create(ctx_frame), FadeIn(ctx_title))

        def add_ctx(text_str, color=GREY_B):
            line = Text(text_str, font="Menlo", font_size=15, color=color)
            if len(ctx_lines) == 0:
                line.next_to(ctx_title, DOWN, aligned_edge=LEFT, buff=0.18)
            else:
                line.next_to(ctx_lines[-1], DOWN, aligned_edge=LEFT, buff=0.1)
            ctx_lines.add(line)
            self.play(FadeIn(line, shift=RIGHT * 0.1), run_time=0.4)
            return line

        # ----- Step 1: caller is M.cube(5). x : Lit 5? No, x is the param of cube;
        # here we focus on stage 1 where the *call site* M.cube(5) drives shapes. -----
        narr1 = Text(
            "Step 1: the call M.cube(5) tells stage 1 that x is Lit 5.",
            font_size=20, color=GREY_B,
        ).next_to(code, DOWN, buff=0.35).align_to(code, LEFT)
        self.play(FadeIn(narr1))
        # Highlight cube body
        cube_box = SurroundingRectangle(code.code_lines[0], color=YELLOW_E, buff=0.05)
        self.play(Create(cube_box))
        add_ctx("cube:  x = Lit 5", GREEN_D)
        self.wait(1.0)

        # ----- Step 2: enter pow with n = Lit 3, x = Lit 5 -----
        narr2 = Text(
            "Step 2: cube(x) calls pow(x, 3), so in pow we know n : Lit 3, x : Lit 5.",
            font_size=20, color=GREY_B,
        ).next_to(code, DOWN, buff=0.35).align_to(code, LEFT)
        self.play(FadeOut(cube_box), FadeTransform(narr1, narr2))
        pow_call_box = SurroundingRectangle(code.code_lines[0][14:22], color=YELLOW_E, buff=0.05)
        self.play(Create(pow_call_box))
        add_ctx("pow:   n = Lit 3,  x = Lit 5", GREEN_D)
        self.wait(1.0)

        # ----- Step 3: dead-branch elimination on `n is 0`. -----
        narr3 = Text(
            "Step 3: n is statically Lit 3, not 0.  The 'then 1' branch is dead.",
            font_size=20, color=GREY_B,
        ).next_to(code, DOWN, buff=0.35).align_to(code, LEFT)
        self.play(FadeOut(pow_call_box), FadeTransform(narr2, narr3))
        dead_box = SurroundingRectangle(code.code_lines[3], color=RED, buff=0.05)
        cross = Cross(dead_box, color=RED, stroke_width=4)
        self.play(Create(dead_box))
        self.play(Create(cross))
        self.wait(1.5)

        # ----- Step 4: take the live branch, decrement n. -----
        narr4 = Text(
            "Step 4: take the live branch.  n shrinks: Lit 3 → Lit 2 → Lit 1 → Lit 0.",
            font_size=20, color=GREY_B,
        ).next_to(code, DOWN, buff=0.35).align_to(code, LEFT)
        live_box = SurroundingRectangle(code.code_lines[4], color=GREEN, buff=0.05)
        self.play(FadeTransform(narr3, narr4), Create(live_box))
        add_ctx("recurse: n = Lit 2", BLUE_C)
        add_ctx("recurse: n = Lit 1", BLUE_C)
        add_ctx("recurse: n = Lit 0", BLUE_C)
        self.wait(0.6)

        # ----- Step 5: base case fires, recursion terminates. -----
        narr5 = Text(
            "Step 5: when n : Lit 0, the base case fires — the 'else' branch is now dead.",
            font_size=20, color=GREY_B,
        ).next_to(code, DOWN, buff=0.35).align_to(code, LEFT)
        self.play(FadeTransform(narr4, narr5))
        # Flip which branch is live/dead for n=0.
        self.play(
            FadeOut(dead_box), FadeOut(cross), FadeOut(live_box),
        )
        live2 = SurroundingRectangle(code.code_lines[3], color=GREEN, buff=0.05)
        dead2 = SurroundingRectangle(code.code_lines[4], color=RED, buff=0.05)
        cross2 = Cross(dead2, color=RED, stroke_width=4)
        self.play(Create(live2), Create(dead2), Create(cross2))
        add_ctx("base:    return Lit 1", GREEN_D)
        self.wait(1.5)

        # ----- Step 6: residual code is x*x*x*1, with no recursion left. -----
        narr6 = Text(
            "Step 6: every recursive call was peeled away — the residual is straight-line code.",
            font_size=20, color=YELLOW_E,
        ).next_to(code, DOWN, buff=0.35).align_to(code, LEFT)
        self.play(FadeTransform(narr5, narr6))

        residual = mls("fun cube(x) = x * x * x * 1").scale(0.7)
        residual.next_to(narr6, DOWN, buff=0.35).align_to(code, LEFT)
        residual_arrow = Arrow(
            code.get_bottom() + DOWN * 0.05,
            residual.get_top() + UP * 0.05,
            color=GREEN_D, stroke_width=3, buff=0.05,
        )
        self.play(FadeIn(residual))
        self.wait(2.5)

        self.play(
            FadeOut(
                VGroup(
                    sub2, code, ctx_grp, narr6, live2, dead2, cross2,
                    residual,
                )
            )
        )

        # =====================================================================
        # Part 3 — try it yourself.  Mention the web demo.
        # =====================================================================
        demo_head = Text(
            "Try it yourself — live in your browser.",
            font_size=30, weight=BOLD, color=YELLOW_E,
        ).next_to(head, DOWN, buff=0.5)
        bullets = VGroup(
            Text("• paste any MLscript module,  add  staged  to the front", font_size=22, color=GREY_B),
            Text("• inspect the inferred shapes side-by-side with the residual", font_size=22, color=GREY_B),
            Text("• step through stage-1 reduction one rule at a time", font_size=22, color=GREY_B),
        ).arrange(DOWN, aligned_edge=LEFT, buff=0.25).next_to(demo_head, DOWN, buff=0.4)

        url = Text(
            "→  web demo at the end of the talk",
            font_size=24, color=GREEN_D,
        ).next_to(bullets, DOWN, buff=0.5)

        self.play(FadeIn(demo_head))
        for b in bullets:
            self.play(FadeIn(b, shift=RIGHT * 0.15), run_time=0.4)
        self.play(FadeIn(url))
        self.wait(3.0)

        self.play(FadeOut(VGroup(head, demo_head, bullets, url)))


# -----------------------------------------------------------------------------
# 6. Novelty — disjunctive shapes
# -----------------------------------------------------------------------------


class Novelty(Scene):
    def construct(self):
        head = section_title("What's new: disjunctive shapes")

        intro = Text(
            "values that could be one of several classes at runtime",
            font_size=26,
            color=GREY_B,
        ).next_to(head, DOWN, buff=0.3)

        code = mls(
            """staged class B1(y) with fun call(x) = x + 2 + y
staged class B2(y) with fun call(x) = x + y

fun pick(b) =
  if b then new B1(2) else new B2(3)
fun use(b) = pick(b).call(5)"""
        ).scale(0.8)
        code.next_to(intro, DOWN, buff=0.4).to_edge(LEFT, buff=0.6)

        shape_lbl = Text("inferred shape:", font_size=24, color=GREY_B)
        shape = MathTex(r"[\![\, B_1(2)\,\cup\,B_2(3)\,]\!]", font_size=44)
        shape_grp = (
            VGroup(shape_lbl, shape)
            .arrange(DOWN, buff=0.3)
            .to_edge(RIGHT, buff=0.6)
            .shift(DOWN * 0.4)
        )

        self.play(FadeIn(head), FadeIn(intro))
        self.play(Write(code))
        self.play(FadeIn(shape_grp))

        contrast = Text(
            "Hybrid Partial Evaluation [Shali & Cook, 2011] cannot specialise across this kind of dispatch.",
            font_size=22,
            color=YELLOW_E,
        ).to_edge(DOWN, buff=0.5)
        memo = Text(
            "Plus: every specialisation is memoised  — addressing [Swadi et al., 2006].",
            font_size=22,
            color=YELLOW_E,
        ).next_to(contrast, UP, buff=0.2)

        self.play(FadeIn(contrast), FadeIn(memo))
        self.wait(7.5)
        self.play(FadeOut(VGroup(head, intro, code, shape_grp, contrast, memo)))


# -----------------------------------------------------------------------------
# 7. Benchmarks
# -----------------------------------------------------------------------------


class Benchmarks(Scene):
    def construct(self):
        head = section_title("Benchmark: 3-D Model-View-Projection")
        sub = Text(
            "16 000 random points · fixed transformation matrix · M1 MacBook Pro",
            font_size=22,
            color=GREY_C,
        ).next_to(head, DOWN, buff=0.2)

        time_chart = BarChart(
            values=[1.46, 0.55],
            bar_names=["original", "staged"],
            bar_colors=[BLUE, ORANGE],
            y_range=[0, 2, 0.5],
            y_length=3.6,
            x_length=5,
            x_axis_config={"font_size": 28},
            y_axis_config={"decimal_number_config": {"unit": "s"}},
        )
        time_lbls = time_chart.get_bar_labels(font_size=32)
        time_grp = VGroup(time_chart, time_lbls)
        time_title = Text("Runtime", font_size=26, weight=BOLD)
        time_box = (
            VGroup(time_title, time_grp)
            .arrange(DOWN, buff=0.2)
            .to_edge(LEFT, buff=0.7)
            .shift(DOWN * 0.4)
        )

        size_chart = BarChart(
            values=[242, 975],
            bar_names=["original", "staged"],
            bar_colors=[BLUE, ORANGE],
            y_range=[0, 1000, 250],
            y_length=3.6,
            x_length=5,
            x_axis_config={"font_size": 28},
            y_axis_config={
                "decimal_number_config": {"unit": "B", "num_decimal_places": 0}
            },
        )
        size_lbls = size_chart.get_bar_labels(font_size=32)
        size_grp = VGroup(size_chart, size_lbls)
        size_title = Text("JS code size", font_size=26, weight=BOLD)
        size_box = (
            VGroup(size_title, size_grp)
            .arrange(DOWN, buff=0.2)
            .to_edge(RIGHT, buff=0.7)
            .shift(DOWN * 0.6)
        )
        # Match heights so the two charts line up.
        time_box.shift(DOWN * 0.2)

        self.play(FadeIn(head), FadeIn(sub))
        self.play(FadeIn(time_box), FadeIn(size_box))
        speedup = Text(
            "2.6× speed-up  (1.46s → 0.55s)",
            font_size=30,
            color=ORANGE,
        ).to_edge(DOWN, buff=0.25)
        self.play(FadeIn(speedup))
        self.wait(4.5)

        self.play(
            FadeOut(VGroup(head, sub, time_box, size_box, speedup)), run_time=0.6
        )


# -----------------------------------------------------------------------------
# 8. Closing
# -----------------------------------------------------------------------------


class Closing(Scene):
    def construct(self):
        line1 = Text("Dynamic Staging", weight=BOLD, font_size=56)
        line2 = Text(
            "high-level code, low-level performance — with one keyword.",
            font_size=28,
            slant=ITALIC,
            color=GREY_B,
        )
        thanks = Text("Thank you!", font_size=36, color=YELLOW)
        VGroup(line1, line2, thanks).arrange(DOWN, buff=0.5).move_to(ORIGIN)

        self.play(FadeIn(line1, shift=UP * 0.2))
        self.play(FadeIn(line2))
        self.play(FadeIn(thanks, scale=0.8))
        self.wait(3.0)


# -----------------------------------------------------------------------------
# Master scene — concatenates every segment into one ~3 minute video.
# -----------------------------------------------------------------------------


class FinalVideo(Scene):
    """Render the full ~3 minute video in one go."""

    def construct(self):
        for cls in (
            TitleCard,
            Motivation,
            MSPApproach,
            OurApproach,
            PowExample,
            Novelty,
            Benchmarks,
            Closing,
        ):
            cls.construct(self)
