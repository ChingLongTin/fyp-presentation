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

# silent typing error because of Manim's type system not conforming to its documentation
# pyright: reportArgumentType=false, reportAssignmentType=false, reportCallIssue=false, reportIndexIssue=false, reportWildcardImportFromLibrary=false, reportAssignmentType=false, reportGeneralTypeIssues=false

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
        tradeoff = Text(
            "Programmers always sacrifice speed for readability & abstraction.",
            font_size=24,
            color=GREY_B,
        )
        tradeoff.next_to(head, DOWN, buff=0.22)

        # 2x2 matrix multiply, then a 45-degree-rotation wrapper that calls it
        # with a constant rotation matrix.
        general = """staged module Matrix with
  fun get(m, i, j) = m.((i * 2) + j)
  fun matmul(a, b) =
    let r0 = (get(a,0,0) * get(b,0,0)) + (get(a,0,1) * get(b,1,0))
    let r1 = (get(a,0,0) * get(b,0,1)) + (get(a,0,1) * get(b,1,1))
    let r2 = (get(a,1,0) * get(b,0,0)) + (get(a,1,1) * get(b,1,0))
    let r3 = (get(a,1,0) * get(b,0,1)) + (get(a,1,1) * get(b,1,1))
    [r0, r1, r2, r3]
fun rotate45(m) =
  let c45 = 0.7071
  let s45 = 0.7071
  Matrix.matmul([c45, -s45, s45, c45], m)"""

        # cos(45°) = sin(45°) = 0.7071, so the four rows collapse to plain
        # additions / subtractions over m.(0..3).
        residual = """fun rotate45(m) =
  [
    (0.7071 * m.(0)) - (0.7071 * m.(2)),
    (0.7071 * m.(1)) - (0.7071 * m.(3)),
    (0.7071 * m.(0)) + (0.7071 * m.(2)),
    (0.7071 * m.(1)) + (0.7071 * m.(3))
  ]"""

        c1 = mls(general).scale(0.40)
        c3 = mls(residual).scale(0.46)

        l1 = Text("What we write", font_size=20, color=GREY_B)
        l3 = Text("What Dynamic Staging produces", font_size=20, color=GREEN_D)

        col1 = VGroup(l1, c1).arrange(DOWN, buff=0.18)
        col3 = VGroup(l3, c3).arrange(DOWN, buff=0.18)

        cols = VGroup(col1, col3).arrange(RIGHT, buff=2.2, aligned_edge=UP)
        cols.next_to(tradeoff, DOWN, buff=0.4)

        arrow_y = c3.get_center()[1]
        arrow = Arrow(
            np.array([c1.get_right()[0] + 0.05, arrow_y, 0]),
            np.array([c3.get_left()[0] - 0.05, arrow_y, 0]),
            buff=0.0,
            color=WHITE,
            stroke_width=5,
        )
        arrow_lbl = Text("Dynamic Staging", font_size=16, color=WHITE).next_to(
            arrow, DOWN, buff=0.08
        )

        self.play(FadeIn(head))
        self.play(FadeIn(tradeoff))
        self.wait(0.4)
        self.play(FadeIn(l1), Write(c1), run_time=1.4)

        what_src = Text(
            "A general 2x2 matrix multiply, used by rotate45 with a constant rotation matrix.",
            font_size=18,
            color=GREY_B,
        ).next_to(cols, DOWN, buff=0.45)
        self.play(FadeIn(what_src))
        self.wait(2.0)

        wasted = SurroundingRectangle(
            VGroup(c1.code_lines[3], c1.code_lines[4],
                   c1.code_lines[5], c1.code_lines[6]),
            color=RED,
            buff=0.04,
        )
        wasted_lbl = Text(
            "Array look-ups every cell",
            font_size=18,
            color=RED_C,
        ).next_to(cols, DOWN, buff=0.45)
        self.play(FadeOut(what_src), Create(wasted), FadeIn(wasted_lbl))
        self.wait(2.0)

        self.play(FadeOut(wasted), FadeOut(wasted_lbl))
        self.play(GrowArrow(arrow), FadeIn(arrow_lbl))

        rot_box = SurroundingRectangle(
            VGroup(c1.code_lines[8], c1.code_lines[9],
                   c1.code_lines[10], c1.code_lines[11]),
            color=YELLOW_E, buff=0.05, stroke_width=2,
        )
        rot_lbl = Text(
            "rotate45 calls Matrix.matmul with a specific argument",
            font_size=18, color=YELLOW_E,
        ).next_to(cols, DOWN, buff=0.45)
        self.play(Create(rot_box), FadeIn(rot_lbl))
        self.wait(1.4)

        self.play(FadeIn(l3), Write(c3), run_time=1.2)

        # Highlight the specialised rotate45 on the right (the residual body)
        # so attention shifts from the source rotate45 to the staged result.
        res_box = SurroundingRectangle(
            c3, color=GREEN_D, buff=0.05, stroke_width=2,
        )
        # Brief explanation of what the residual is doing.
        what_res = Text(
            "Constants baked in. Only necessary lookup remains",
            font_size=18,
            color=GREEN_D,
        ).next_to(cols, DOWN, buff=0.45)
        self.play(
            FadeOut(rot_lbl),
            FadeOut(rot_box),
            Create(res_box),
            FadeIn(what_res),
        )
        self.wait(1.4)

        bottom = Text(
            "Our Goal: keep the abstract version; let the compiler produce the efficient one.",
            font_size=20,
            color=GREEN_D,
        ).next_to(what_res, DOWN, buff=0.18)
        self.play(FadeIn(bottom))
        self.wait(3.5)
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
                    res_box,
                    what_res,
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
            lines[3][10:12],        # .~  (only the splice, not the `(`)
            lines[3][-2:],          # >.  (drop the trailing `)`)
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
# 4. Our approach
# -----------------------------------------------------------------------------


class OurApproach(Scene):
    def construct(self):
        head = Text(
            "Same pipeline, far less ceremony",
            weight=BOLD,
            font_size=42,
        ).to_edge(UP)
        self.play(FadeIn(head))

        # =====================================================================
        # Helper: build a pipeline row for one approach.
        #   [label]  source  ── stage 1 ──▶  residual  ── stage 2 ──▶  Result: 125
        # =====================================================================
        def build_row(label_str, label_color, src_code, residual_code,
                       res_lbl_text):
            row_label = Text(label_str, weight=BOLD, font_size=22,
                             color=label_color)
            src_lbl = Text("source", font_size=14, color=GREY_B)
            src_grp = VGroup(src_lbl, src_code).arrange(DOWN, buff=0.1)

            res_lbl = Text(res_lbl_text, font_size=14, color=GREY_B)
            res_grp = VGroup(res_lbl, residual_code).arrange(DOWN, buff=0.1)

            value_text = Text("125", font="Menlo", weight=BOLD,
                              font_size=30, color=GREEN_D)
            value_lbl = Text("Result", font_size=14, color=GREY_B)
            value_grp = VGroup(value_lbl, value_text).arrange(DOWN, buff=0.1)

            arr1_zone = Rectangle(width=1.4, height=0.01).set_opacity(0)
            arr2_zone = Rectangle(width=1.4, height=0.01).set_opacity(0)

            row = VGroup(
                row_label, src_grp, arr1_zone, res_grp, arr2_zone, value_grp,
            ).arrange(RIGHT, buff=0.35, aligned_edge=ORIGIN)

            arr1 = Arrow(
                arr1_zone.get_left(), arr1_zone.get_right(),
                buff=0.0, color=YELLOW_E, stroke_width=3,
                max_tip_length_to_length_ratio=0.15,
            )
            arr1_lbl = Text("stage 1", font_size=14, color=YELLOW_E)
            arr1_lbl.next_to(arr1, UP, buff=0.08)

            arr2 = Arrow(
                arr2_zone.get_left(), arr2_zone.get_right(),
                buff=0.0, color=YELLOW_E, stroke_width=3,
                max_tip_length_to_length_ratio=0.15,
            )
            arr2_lbl = Text("stage 2", font_size=14, color=YELLOW_E)
            arr2_lbl.next_to(arr2, UP, buff=0.08)

            return {
                "label": row_label,
                "src_grp": src_grp, "src_code": src_code,
                "res_grp": res_grp,
                "value_grp": value_grp,
                "arr1": arr1, "arr1_lbl": arr1_lbl,
                "arr2": arr2, "arr2_lbl": arr2_lbl,
                "row": row,
            }

        # =====================================================================
        # MSP row (top): function-level, heavily annotated source.
        # =====================================================================
        msp_src_text = """fun pow(n, x) = if n is
  0 then .<1>.
  else .<.~x * .~(pow(n-1, x))>."""
        msp_src = mls(msp_src_text).scale(0.45)

        # MSP residual at function level: cube specialised.
        msp_residual_text = """fun cube(x) = x * x * x * 1"""
        msp_residual = mls(msp_residual_text).scale(0.5)

        msp = build_row(
            "MSP", ORANGE, msp_src, msp_residual, "residual function",
        )

        # =====================================================================
        # Dynamic Staging row (bottom): just the `staged` keyword.
        # =====================================================================
        ds_src_text = """staged module M with
  fun pow(n, x) = if n is
    0 then 1
    else x * pow(n-1, x)
  fun cube(x) = pow(x, 3)"""
        ds_src = mls(ds_src_text).scale(0.42)

        ds_residual_text = """module M with
  fun pow0(x) = 1
  fun pow1(x) = x*pow0(x)
  fun pow2(x) = x*pow1(x)
  fun pow3(x) = x*pow2(x)
  fun cube(x) = pow3(x)"""
        ds_residual = mls(ds_residual_text).scale(0.4)

        ds = build_row(
            "Dynamic Staging", GREEN_D, ds_src, ds_residual, "residual module",
        )

        # =====================================================================
        # Stack the two rows vertically and align them column-by-column.
        # =====================================================================
        stack = VGroup(msp["row"], ds["row"]).arrange(DOWN, buff=1.0)
        stack.move_to(ORIGIN).shift(DOWN * 0.2)

        # Column-align src_grp / res_grp / value_grp between the two rows,
        # anchored on whichever row has the wider element.
        for key in ("src_grp", "res_grp", "value_grp"):
            tgt_x = max(msp[key].get_center()[0], ds[key].get_center()[0])
            for row in (msp, ds):
                row[key].move_to(np.array(
                    [tgt_x, row[key].get_center()[1], 0]))

        # Re-derive arrow positions for both rows so they sit between the
        # newly-aligned columns.
        for row in (msp, ds):
            y = row["src_grp"].get_center()[1]
            x1_l = row["src_grp"].get_right()[0] + 0.1
            x1_r = row["res_grp"].get_left()[0] - 0.1
            x2_l = row["res_grp"].get_right()[0] + 0.1
            x2_r = row["value_grp"].get_left()[0] - 0.1
            row["arr1"].put_start_and_end_on(
                np.array([x1_l, y, 0]), np.array([x1_r, y, 0]))
            row["arr2"].put_start_and_end_on(
                np.array([x2_l, y, 0]), np.array([x2_r, y, 0]))
            row["arr1_lbl"].next_to(row["arr1"], UP, buff=0.06)
            row["arr2_lbl"].next_to(row["arr2"], UP, buff=0.06)

        # Place row labels just left of each row.
        for row in (msp, ds):
            row["label"].next_to(row["src_grp"], LEFT, buff=0.4)
            row["label"].set_y(row["src_grp"].get_center()[1])

        # =====================================================================
        # Animate MSP row.
        # =====================================================================
        self.play(
            FadeIn(msp["label"]),
            FadeIn(msp["src_grp"]),
        )

        # Highlight the heavy MSP annotation regions.
        msp_lines = msp_src.code_lines
        # code_lines strips whitespace, so indices are over visible glyphs only.
        # Line 1 glyphs: "0then.<1>."                       → ".<1>." starts at 5
        # Line 2 glyphs: "else.<.~x*.~(pow(n-1,x))>."       → annotation starts at 4
        annot_box = VGroup(
            SurroundingRectangle(
                msp_lines[1][5:], color=YELLOW, buff=0.03, stroke_width=2,
            ).set_fill(YELLOW).set_opacity(0),
            SurroundingRectangle(
                msp_lines[2][4:], color=YELLOW, buff=0.03, stroke_width=2,
            ).set_fill(YELLOW).set_opacity(0),
        )
        self.add(annot_box)
        self.play(annot_box.animate.set_opacity(0.35), run_time=0.6)

        msp_caption = Text(
            "MSP needs cumbersome quote/splice annotations on every dynamic computation.",
            font_size=18, color=ORANGE,
        )
        msp_caption.next_to(msp["src_grp"], DOWN, buff=0.25).align_to(
            msp["src_grp"], LEFT)
        self.play(FadeIn(msp_caption))
        self.wait(0.6)

        self.play(GrowArrow(msp["arr1"]), FadeIn(msp["arr1_lbl"]))
        self.play(FadeIn(msp["res_grp"]))
        self.play(GrowArrow(msp["arr2"]), FadeIn(msp["arr2_lbl"]))
        self.play(FadeIn(msp["value_grp"]))
        self.wait(0.4)
        self.play(FadeOut(msp_caption))

        # =====================================================================
        # Animate Dynamic Staging row.
        # =====================================================================
        self.play(
            FadeIn(ds["label"]),
            FadeIn(ds["src_grp"]),
        )

        kw_line = ds_src.code_lines[0]
        kw_width = kw_line.width * (len("staged") / len("staged module M with"))
        kw_box = Rectangle(
            width=kw_width + 0.06,
            height=kw_line.height + 0.06,
            stroke_color=YELLOW,
            stroke_width=2,
            fill_color=YELLOW,
            fill_opacity=0.45,
        )
        kw_box.move_to(np.array([
            kw_line.get_left()[0] + kw_width / 2,
            kw_line.get_center()[1], 0,
        ]))
        self.play(Create(kw_box), Flash(kw_box, color=YELLOW, line_length=0.2))

        ds_caption = Text(
            "Trades annotations for a single keyword \"staged\".",
            font_size=18, color=GREEN_D,
        )
        ds_caption.next_to(ds["src_grp"], DOWN, buff=0.25).align_to(
            ds["src_grp"], LEFT)
        self.play(FadeIn(ds_caption))
        self.wait(0.6)

        self.play(GrowArrow(ds["arr1"]), FadeIn(ds["arr1_lbl"]))
        self.play(FadeIn(ds["res_grp"]))
        self.play(GrowArrow(ds["arr2"]), FadeIn(ds["arr2_lbl"]))
        self.play(FadeIn(ds["value_grp"]))
        self.wait(0.4)
        self.play(FadeOut(ds_caption))

        punchline = Text(
            "Same two-stage pipeline; staging trades annotations for a single keyword.",
            font_size=20, color=YELLOW_E,
        ).to_edge(DOWN, buff=0.4)
        self.play(FadeIn(punchline))
        self.wait(3.0)

        # =====================================================================
        # Transition to the next scene: zoom the dynamic-staging *stage 1*
        # =====================================================================
        # First, fade everything except the DS stage-1 arrow and its label.
        self.play(FadeOut(VGroup(
            head,
            msp["label"], msp["src_grp"], annot_box,
            msp["arr1"], msp["arr1_lbl"], msp["res_grp"],
            msp["arr2"], msp["arr2_lbl"], msp["value_grp"],
            ds["label"], ds["src_grp"], kw_box,
            ds["res_grp"],
            ds["arr2"], ds["arr2_lbl"], ds["value_grp"],
            punchline,
        )))

        next_title = Text(
            "Stage 1: symbolic execution", weight=BOLD, font_size=42,
        ).to_edge(UP)
        self.play(
            FadeTransform(VGroup(ds["arr1"], ds["arr1_lbl"]), next_title),
            run_time=1.0,
        )
        self.wait(0.4)


# -----------------------------------------------------------------------------
# 5. Worked example — pow
# -----------------------------------------------------------------------------


class PowExample(Scene):
    def construct(self):
        # The previous scene (OurApproach) ends by morphing its DS stage-1
        # arrow into this exact title at the top of the frame.  We `add`
        # rather than `play(FadeIn(...))` so the cut between clips is
        # visually seamless when build_video.sh concatenates them.
        head = section_title("Stage 1: symbolic execution")
        self.add(head)

        # =================================================================
        # Lay out CODE  +  SPECIALIZED FUNCTIONS  +  SHAPE CONTEXT
        # so the three blocks align at the top.  We keep the *whole* module
        # in the code block — including the parts we are not specialising —
        # so the code block stays tall enough to line up with the right-
        # hand stack of two tables.
        # =================================================================
        body_src = """staged module M with
  fun pow(n, x) = if n is
    0 then 1
    else x * pow(n - 1, x)
  fun cube(x) = pow(x, 3)
M.cube(5)"""
        code = mls(body_src).scale(0.55)
        ROW_H = 0.42

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
            # 5th row reserved for `cube(x)` — added to the cache after the
            # symbolic-execution loop completes.
            ("cube(x)", "pow3(x)"),
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
        sf_grp = VGroup(sf_title, sf_frame, sf_div, *sf_hdr,
                        *(c for r in sf_rows for c in r))

        # --- Shape Context table ---
        SC_COL_LEFT = [0.0, 1.1]
        sc_hdr = (
            Text("Variable", font_size=16, weight=BOLD, color=BLUE_C),
            Text("Shape", font_size=16, weight=BOLD, color=BLUE_C),
        )
        ph_rows = []
        for j in range(2):
            v = Text("recurse", font="Menlo", font_size=15, color=GREY_B)
            s = Text("Lit 3", font="Menlo", font_size=15, color=GREY_B)
            place_row((v, s), SC_COL_LEFT, -(j + 1) * ROW_H - 0.12)
            ph_rows.extend([v, s])
        place_row(sc_hdr, SC_COL_LEFT, 0.0)
        sc_cells_for_frame = VGroup(*sc_hdr, *ph_rows)
        sc_frame = SurroundingRectangle(
            sc_cells_for_frame, color=BLUE_C, buff=0.28, corner_radius=0.1
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
        sc_grp = VGroup(sc_title, sc_frame, sc_div, *sc_hdr)

        # --- Status label that lives directly above the code block. ----------
        status_label = Text("Now specializing:", font_size=18, color=GREY_B)
        status_call = Text("(idle)", font="Menlo", font_size=20, color=YELLOW_E)
        status = VGroup(status_label, status_call).arrange(RIGHT, buff=0.2,
                                                           aligned_edge=DOWN)
        code_with_status = VGroup(status, code).arrange(DOWN, buff=0.2,
                                                       aligned_edge=LEFT)

        # --- Stack the two tables, then place the (status+code) column to
        # their left so the *top borders* of all three blocks align. ----------
        tables = VGroup(sf_grp, sc_grp).arrange(
            DOWN, aligned_edge=LEFT, buff=0.45,
        )
        tables.scale(0.85)

        layout = (
            VGroup(code_with_status, tables)
            .arrange(RIGHT, buff=1.0, aligned_edge=UP)
            .move_to(ORIGIN)
            .shift(DOWN * 0.05)
        )
        self.play(Write(code), FadeIn(status), run_time=1.8)

        legend = Text(
            "Dyn = unknown until runtime",
            font_size=16,
            color=GREY_B,
            slant=ITALIC,
        ).next_to(tables, DOWN, buff=0.25).align_to(tables, LEFT)

        # Hide SF rows initially.
        sf_rows_grp = VGroup(*(c for r in sf_rows for c in r))
        sf_rows_grp.set_opacity(0)

        self.play(
            Create(sf_frame),
            FadeIn(VGroup(sf_title, sf_div, *sf_hdr)),
            Create(sc_frame),
            FadeIn(VGroup(sc_title, sc_div, *sc_hdr)),
            FadeIn(legend),
            run_time=1.2,
        )
        self.wait(0.6)

        # =================================================================
        # Helper utilities for the animation-driven walk-through.
        # All run-times are scaled 1.5× compared with the previous version.
        # =================================================================
        sc_rows_visible = []  # list of VGroup(var_text, shape_text)
        # Track the *current* status_call mobject so we can fade it out at
        # scene end (each set_status() returns a brand-new Text object).
        status_ref = {"call": status_call}

        def set_status(call_str):
            new = Text(call_str, font="Menlo", font_size=20, color=YELLOW_E)
            new.next_to(status_label, RIGHT, buff=0.2, aligned_edge=DOWN)
            self.play(FadeTransform(status_ref["call"], new), run_time=0.7)
            status_ref["call"] = new
            # Briefly draw a yellow box around the status line so the viewer's
            # eye is pulled to the change.
            box = SurroundingRectangle(
                VGroup(status_label, new),
                color=YELLOW, buff=0.08, stroke_width=2,
            )
            self.play(Create(box), run_time=0.3)
            self.play(FadeOut(box), run_time=0.3)
            return new

        def set_shape_ctx(bindings):
            old = VGroup(*sc_rows_visible) if sc_rows_visible else None
            sc_rows_visible.clear()
            new_rows = []
            for i, (v, s) in enumerate(bindings):
                vt = Text(v, font="Menlo", font_size=15, color=GREY_B)
                st = Text(s, font="Menlo", font_size=15, color=GREEN_D)
                row = VGroup(vt, st)
                row.scale(0.85)
                target_y = (
                    sc_hdr[0].get_bottom()[1]
                    - 0.18
                    - (i + 0.5) * (sc_hdr[0].height + 0.18)
                )
                vt.align_to(sc_hdr[0], LEFT)
                st.align_to(sc_hdr[1], LEFT)
                vt.set_y(target_y)
                st.set_y(target_y)
                new_rows.append(row)
                sc_rows_visible.append(row)
            anims = []
            if old is not None:
                anims.append(FadeOut(old, run_time=0.45))
            anims.extend(FadeIn(r, shift=RIGHT * 0.1) for r in new_rows)
            self.play(*anims, run_time=0.85)
            return new_rows

        def flash_ctx_row(idx):
            if idx >= len(sc_rows_visible):
                return
            row = sc_rows_visible[idx]
            box = SurroundingRectangle(row, color=YELLOW, buff=0.06, stroke_width=2)
            self.play(Create(box), run_time=0.4)
            self.play(Indicate(row, color=YELLOW, scale_factor=1.15), run_time=0.75)
            self.play(FadeOut(box), run_time=0.3)

        # =================================================================
        # Step 0: cube initiates the call pow(x, 3).
        # =================================================================
        cube_box = SurroundingRectangle(code.code_lines[4], color=YELLOW, buff=0.04)
        self.play(Create(cube_box), run_time=0.6)
        self.wait(1.0)
        self.play(FadeOut(cube_box), run_time=0.4)

        # =================================================================
        # Walk through the four symbolic-execution iterations.  We highlight
        # the code lines of pow's body; the full module stays on screen so
        # the three blocks remain top-aligned for the whole scene.
        # =================================================================
        if_line = code.code_lines[1]   # "  fun pow(n, x) = if n is"
        then_line = code.code_lines[2] # "    0 then 1"
        else_line = code.code_lines[3] # "    else x * pow(n - 1, x)"

        status_call = set_status("pow(x, 3)")
        set_shape_ctx([("n", "Lit 3"), ("x", "Dyn")])

        for i in range(4):
            k = 3 - i
            if i > 0:
                status_call = set_status(f"pow(x, {k})")
                set_shape_ctx([("n", f"Lit {k}"), ("x", "Dyn")])

            # (b) Flash the if-line with a clean surrounding box (no
            # Indicate / no inner slice — both produced a stray yellow
            # square at certain font sizes).  Then flash the n row in
            # the shape context to show that n's shape is being read.
            if_box = SurroundingRectangle(
                if_line, color=YELLOW, buff=0.04, stroke_width=2,
            )
            self.play(Create(if_box), run_time=0.45)
            flash_ctx_row(0)
            self.play(FadeOut(if_box), run_time=0.3)
            self.wait(0.15)

            # (c) Animate the dead branch crossing out, the live one glowing.
            if k > 0:
                dead, live = then_line, else_line
            else:
                dead, live = else_line, then_line
            dead_box = SurroundingRectangle(dead, color=RED, buff=0.04)
            cross = Cross(dead_box, color=RED, stroke_width=4)
            live_box = SurroundingRectangle(live, color=GREEN_D, buff=0.04)
            self.play(Create(dead_box), Create(cross), run_time=0.85)
            self.play(
                dead.animate.set_opacity(0.25),
                Create(live_box),
                run_time=0.75,
            )

            # (d) Move a copy of the live branch toward the cache row, then
            # morph it into the pre-built specialised body cell.
            target_body_cell = sf_rows[i][1]
            live_copy = live.copy()
            self.play(
                live_copy.animate
                    .scale(0.55)
                    .move_to(target_body_cell.get_center()),
                run_time=1.35,
            )
            sf_rows[i][0].set_opacity(1)
            target_body_cell.set_opacity(1)
            self.play(
                FadeIn(sf_rows[i][0], shift=RIGHT * 0.15),
                FadeTransform(live_copy, target_body_cell),
                run_time=0.9,
            )
            self.wait(0.6)

            # Reset the code block for the next iteration.
            self.play(
                FadeOut(dead_box),
                FadeOut(cross),
                FadeOut(live_box),
                dead.animate.set_opacity(1.0),
                run_time=0.55,
            )

        # =================================================================
        # Final step.  Now that all four pow-specialisations are in the
        # cache, we:
        #   (1) rewrite  pow(x, 3)  inside cube's body to a direct call to
        #       the cached pow3(x);
        #   (2) record cube itself as a NEW (5th) cache entry whose body is
        #       just  pow3(x)  \u2014 we do NOT overwrite pow3 at this stage;
        #   (3) reveal  M.cube(5)  in the source.  Because that's the only
        #       site using module M, the dead pow_i specialisations can be
        #       eliminated, and inlining gives  cube(x) = x * x * x.
        # =================================================================
        cube_line = code.code_lines[4]
        cube_focus_box = SurroundingRectangle(
            cube_line, color=BLUE_C, buff=0.04, stroke_width=2,
        )
        self.play(Create(cube_focus_box), run_time=0.6)
        self.wait(0.4)

        # ---- Step (1): rewrite pow(x, 3) \u2192 pow3(x) inside cube. ---------
        cube_after_full = mls("  fun cube(x) = pow3(x)").scale(0.55)
        cube_after = cube_after_full.code_lines[0]
        cube_after.move_to(cube_line, aligned_edge=LEFT)
        replaced_msg = Text(
            "pow(x, 3) is in the cache  \u2192  call pow3(x) directly.",
            font_size=20, color=BLUE_C, weight=BOLD,
        ).to_edge(DOWN, buff=0.4)
        self.play(
            FadeTransform(cube_line, cube_after),
            FadeIn(replaced_msg),
            run_time=1.1,
        )
        # Hide the original cube_line so the final FadeOut(code) does not
        # briefly redraw the now-stale  fun cube(x) = pow(x, 3)  line.
        cube_line.set_opacity(0)
        self.remove(cube_line)
        self.wait(1.4)

        # ---- Step (2): add cube as a NEW cache row (does not replace pow3).
        add_msg = Text(
            "Cache cube(x) too. Its body is just pow3(x).",
            font_size=20, color=YELLOW_E, weight=BOLD,
        ).to_edge(DOWN, buff=0.4)
        self.play(FadeTransform(replaced_msg, add_msg), run_time=0.8)
        self.play(
            sf_rows[4][0].animate.set_opacity(1),
            sf_rows[4][1].animate.set_opacity(1),
            run_time=0.9,
        )
        self.wait(1.2)

        # ---- Step (3): highlight  M.cube(5)  — already visible in source.
        entry_line = code.code_lines[5]
        entry_box = SurroundingRectangle(
            entry_line, color=GREEN_D, buff=0.04, stroke_width=2,
        )
        entry_msg = Text(
            "M.cube(5) is the only entry point that uses module M.",
            font_size=20, color=GREEN_D, weight=BOLD,
        ).to_edge(DOWN, buff=0.4)
        self.play(
            FadeOut(cube_focus_box),
            FadeTransform(add_msg, entry_msg),
            run_time=0.9,
        )
        self.play(Create(entry_box), run_time=0.6)
        self.wait(1.6)

        # ---- Step (4): inline pow3(x) body into cube — fold the chain
        inline_msg = Text(
            "Inline pow3's body into cube  \u2192  cube(x) = x * x * x.",
            font_size=22, color=GREEN_D, weight=BOLD,
        ).to_edge(DOWN, buff=0.4)
        self.play(FadeTransform(entry_msg, inline_msg), run_time=0.8)

        cube_inlined_full = mls("  fun cube(x) = x * x * x").scale(0.55)
        cube_inlined = cube_inlined_full.code_lines[0]
        cube_inlined.move_to(cube_after, aligned_edge=LEFT)

        new_cube_body = Text("x * x * x", font="Menlo", font_size=15,
                             color=GREEN_D)
        new_cube_body.scale(0.85)
        new_cube_body.move_to(sf_rows[4][1].get_center()).align_to(
            sf_rows[4][1], LEFT)

        self.play(
            FadeTransform(cube_after, cube_inlined),
            FadeTransform(sf_rows[4][1], new_cube_body),
            run_time=1.0,
        )
        cube_after.set_opacity(0)
        sf_rows[4][1].set_opacity(0)
        self.remove(cube_after, sf_rows[4][1])
        self.wait(1.2)

        # ---- Step (5): now that nothing references pow0-pow3, drop them.
        elim_msg = Text(
            "pow0 to pow3 are unreachable  \u21d2  drop them.",
            font_size=22, color=RED_C, weight=BOLD,
        ).to_edge(DOWN, buff=0.4)
        self.play(FadeTransform(inline_msg, elim_msg), run_time=0.7)

        dead_rows = VGroup(
            sf_rows[0][0], sf_rows[0][1],
            sf_rows[1][0], sf_rows[1][1],
            sf_rows[2][0], sf_rows[2][1],
            sf_rows[3][0], sf_rows[3][1],
        )
        # Cross out, then fade away.
        cross_lines = VGroup(*[
            Line(r.get_left() + LEFT * 0.05, r.get_right() + RIGHT * 0.05,
                 color=RED, stroke_width=2)
            for r in (sf_rows[0][1], sf_rows[1][1],
                      sf_rows[2][1], sf_rows[3][1])
        ])
        self.play(Create(cross_lines), run_time=0.7)
        self.wait(0.5)
        self.play(
            FadeOut(dead_rows),
            FadeOut(cross_lines),
            run_time=1.0,
        )
        for m in dead_rows:
            m.set_opacity(0)
        self.remove(*dead_rows)

        cube_fn_target_pos = sf_rows[0][0].get_center().copy()
        cube_body_target_pos = sf_rows[0][1].get_center().copy()
        self.play(
            sf_rows[4][0].animate.move_to(cube_fn_target_pos),
            new_cube_body.animate.move_to(cube_body_target_pos),
            run_time=0.9,
        )

        # Pause so the viewer can fully read   cube(x) = x * x * x.
        self.wait(2.0)

        # ---- Step (6): with the recursion fully unrolled
        call_msg = Text(
            "Drop  staged  — M is now a plain module; inline M.cube(5) too.",
            font_size=22, color=GREEN_D, weight=BOLD,
        ).to_edge(DOWN, buff=0.4)
        self.play(FadeTransform(elim_msg, call_msg), run_time=0.7)

        # Morph  `staged module M with`  →  `module M with`  in place.
        plain_module_src = mls("module M with").scale(0.55)
        plain_module_line = plain_module_src.code_lines[0]
        plain_module_line.move_to(
            code.code_lines[0], aligned_edge=LEFT,
        )

        # Morph  `M.cube(5)`  →  `5 * 5 * 5`  in place.
        inlined_call_src = mls("5 * 5 * 5").scale(0.55)
        inlined_call_line = inlined_call_src.code_lines[0]
        inlined_call_line.move_to(
            code.code_lines[5], aligned_edge=LEFT,
        )

        self.play(
            FadeTransform(code.code_lines[0], plain_module_line),
            FadeTransform(code.code_lines[5], inlined_call_line),
            FadeOut(entry_box),
            run_time=1.2,
        )
        # Keep the originals from re-appearing during the final FadeOut.
        code.code_lines[0].set_opacity(0)
        code.code_lines[5].set_opacity(0)
        self.remove(code.code_lines[0], code.code_lines[5])
        self.wait(2.5)

        self.play(
            FadeOut(VGroup(
                head, status, status_ref["call"], code, cube_inlined,
                legend,
                sf_grp, sc_grp, *sc_rows_visible, call_msg,
                sf_rows[4][0], new_cube_body,
                plain_module_line, inlined_call_line,
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
# 6. Novelty — other features of dynamic staging
# -----------------------------------------------------------------------------


class Novelty(Scene):
    def construct(self):
        head = section_title("Other features of Dynamic Staging")
        self.play(FadeIn(head))

        # =====================================================================
        # Part 1 — staged classes + disjunctive shapes.
        # =====================================================================
        part1 = Text(
            "1. Beyond modules: stage classes too, with disjunctive shapes.",
            font_size=26, weight=BOLD, color=GREEN_D,
        ).next_to(head, DOWN, buff=0.35)
        self.play(FadeIn(part1, shift=RIGHT * 0.2))

        code = mls(
            """staged class B1(y) with fun call(x) = x + 2 + y
staged class B2(y) with fun call(x) = x + y

fun pick(b) =
  if b then new B1(2) else new B2(3)
fun use(b) = pick(b).call(5)"""
        ).scale(0.7)
        code.next_to(part1, DOWN, buff=0.45).to_edge(LEFT, buff=0.6)

        shape_lbl = Text("inferred shape of pick(b):",
                         font_size=22, color=GREY_B)
        shape = MathTex(r"B_1(2)\,\cup\,B_2(3)", font_size=44, color=YELLOW_E)
        shape_grp = (
            VGroup(shape_lbl, shape)
            .arrange(DOWN, buff=0.3)
            .to_edge(RIGHT, buff=0.6)
        )
        shape_grp.set_y(code.get_center()[1])

        self.play(Write(code))
        kw_box1 = SurroundingRectangle(
            code.code_lines[0][:11], color=YELLOW, buff=0.04, stroke_width=2,
        )
        kw_box2 = SurroundingRectangle(
            code.code_lines[1][:11], color=YELLOW, buff=0.04, stroke_width=2,
        )
        self.play(Create(kw_box1), Create(kw_box2), run_time=0.6)
        self.wait(0.6)

        self.play(FadeIn(shape_lbl))
        self.play(Write(shape))
        union_lbl = Text(
            "Union shape: track every class the value could be at runtime.",
            font_size=22, color=GREEN_D,
        ).to_edge(DOWN, buff=0.55)
        self.play(FadeIn(union_lbl))
        self.wait(2.0)

        contrast = Text(
            "Hybrid Partial Evaluation [Shali & Cook, 2011] gives up here — we don't.",
            font_size=22, color=YELLOW_E,
        ).to_edge(DOWN, buff=0.2)
        self.play(FadeIn(contrast))
        self.wait(2.5)

        self.play(FadeOut(VGroup(
            part1, code, kw_box1, kw_box2, shape_grp, union_lbl, contrast,
        )))

        # =====================================================================
        # Part 2 — @dynamic annotation: opt-out of specialising a parameter.
        # =====================================================================
        part2 = Text(
            "2. @dynamic: opt out of specialising a parameter.",
            font_size=26, weight=BOLD, color=GREEN_D,
        ).next_to(head, DOWN, buff=0.35)
        self.play(FadeIn(part2, shift=RIGHT * 0.2))

        explain = Text(
            "By default the staged compiler specialises on every argument it can.\n"
            "Sometimes you only want to specialise on some of them.",
            font_size=22, color=GREY_B,
        ).next_to(part2, DOWN, buff=0.3)
        self.play(FadeIn(explain))
        self.wait(0.6)

        # The pow signature itself, animated from `pow(x, n)` -> `pow(@dynamic x, n)`.
        sig_before = mls("fun pow(x, n) = ...").scale(0.95)
        sig_after = mls("fun pow(@dynamic x, n) = ...").scale(0.95)
        sig_before.next_to(explain, DOWN, buff=0.6)
        sig_after.move_to(sig_before, aligned_edge=LEFT)

        self.play(Write(sig_before))
        self.wait(0.4)

        ann_caption = Text(
            "Mark x as @dynamic — staging will keep x as a runtime value.",
            font_size=22, color=YELLOW_E,
        ).next_to(sig_after, DOWN, buff=0.4)
        self.play(FadeTransform(sig_before, sig_after), FadeIn(ann_caption))

        # Highlight the @dynamic token.
        ann_box = SurroundingRectangle(
            sig_after.code_lines[0][7:15],  # "@dynamic" glyphs
            color=YELLOW, buff=0.04, stroke_width=2,
        )
        self.play(Create(ann_box), Flash(ann_box, color=YELLOW, line_length=0.2))
        self.wait(1.0)

        # Show what happens when the user calls pow(2, 3): only n is
        # specialised; x stays symbolic.
        call_line = Text("pow(2, 3)", font="Menlo", weight=BOLD,
                         font_size=32, color=GREY_B)
        arrow = Arrow(LEFT * 0.6, RIGHT * 0.6, buff=0.0,
                      color=YELLOW_E, stroke_width=4,
                      max_tip_length_to_length_ratio=0.2)
        residual = mls("pow3(x) = x * x * x").scale(0.9)
        residual_lbl = Text("residual (specialised on n=3 only)",
                            font_size=18, color=GREEN_D)
        residual_grp = VGroup(residual_lbl, residual).arrange(DOWN, buff=0.15)

        chain = VGroup(call_line, arrow, residual_grp).arrange(
            RIGHT, buff=0.5,
        ).next_to(ann_caption, DOWN, buff=0.6)

        self.play(FadeOut(ann_caption))
        self.play(FadeIn(call_line))
        self.play(GrowArrow(arrow))
        self.play(FadeIn(residual_grp))
        self.wait(0.6)

        # Highlight the surviving `x` in the residual to drive the point home.
        x_box = SurroundingRectangle(
            residual.code_lines[0][5:6],  # "pow3(x"
            color=YELLOW, buff=0.04, stroke_width=2,
        )
        kept = Text(
            "x stays a runtime parameter — only n=3 is baked in.",
            font_size=22, color=GREEN_D, weight=BOLD,
        ).to_edge(DOWN, buff=0.45)
        self.play(Create(x_box), FadeIn(kept))
        self.wait(3.0)

        self.play(FadeOut(VGroup(
            head, part2, explain, sig_after, ann_box,
            call_line, arrow, residual_grp, x_box, kept,
        )))


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
        time_title = Text("Runtime (lower is better)", font_size=24, weight=BOLD)
        time_box = (
            VGroup(time_title, time_grp)
            .arrange(DOWN, buff=0.2)
            .to_edge(LEFT, buff=0.7)
            .shift(DOWN * 0.4)
        )

        # JS code size — 27K (vanilla compile) vs 73K (dynamic-staging output).
        size_chart = BarChart(
            values=[27, 73],
            bar_names=["original", "staged"],
            bar_colors=[BLUE, ORANGE],
            y_range=[0, 80, 20],
            y_length=3.6,
            x_length=5,
            x_axis_config={"font_size": 28},
            y_axis_config={
                "decimal_number_config": {"unit": "K", "num_decimal_places": 0}
            },
        )
        size_lbls = size_chart.get_bar_labels(font_size=32)
        size_grp = VGroup(size_chart, size_lbls)
        size_title = Text("JS code size", font_size=24, weight=BOLD)
        size_box = (
            VGroup(size_title, size_grp)
            .arrange(DOWN, buff=0.2)
            .to_edge(RIGHT, buff=0.7)
            .shift(DOWN * 0.6)
        )
        # Match heights so the two charts line up.
        time_box.shift(DOWN * 0.2)

        self.play(FadeIn(head), FadeIn(sub))

        # Animate the bars: draw the axes + titles first, then grow the
        # bars from the x-axis upwards while their numeric labels fade in.
        # `time_lbls` / `size_lbls` are positioned relative to bar tops, so
        # we hide them until the growth completes.
        time_lbls.set_opacity(0)
        size_lbls.set_opacity(0)
        for bar in time_chart.bars:
            bar.stretch_to_fit_height(0.001, about_edge=DOWN)
        for bar in size_chart.bars:
            bar.stretch_to_fit_height(0.001, about_edge=DOWN)
        self.play(FadeIn(time_box), FadeIn(size_box))

        # Re-derive the target heights from the chart's value-to-coordinate
        # mapping so the bars grow to exactly the right pixel height.
        def _grow(chart, values):
            anims = []
            for bar, v in zip(chart.bars, values):
                target_h = abs(
                    chart.y_axis.number_to_point(v)[1]
                    - chart.y_axis.number_to_point(0)[1]
                )
                anims.append(
                    bar.animate.stretch_to_fit_height(
                        target_h, about_edge=DOWN)
                )
            return anims

        self.play(
            *_grow(time_chart, [1.46, 0.55]),
            *_grow(size_chart, [27, 73]),
            run_time=1.4,
        )
        self.play(
            time_lbls.animate.set_opacity(1),
            size_lbls.animate.set_opacity(1),
            run_time=0.4,
        )
        self.wait(0.4)

        speedup = Text(
            "2.6x speed-up  (1.46s → 0.55s)",
            font_size=32,
            color=ORANGE,
            weight=BOLD,
        ).to_edge(DOWN, buff=0.55)
        self.play(FadeIn(speedup, scale=0.9))
        self.wait(1.6)

        # Tradeoff takeaway: code size is cheap, time is expensive.
        tradeoff = Text(
            "We trade code size (cheap) for time (expensive).",
            font_size=24,
            color=GREEN_D,
            weight=BOLD,
        ).to_edge(DOWN, buff=0.2)
        self.play(FadeOut(speedup), FadeIn(tradeoff))
        self.wait(3.0)

        self.play(
            FadeOut(VGroup(head, sub, time_box, size_box, tradeoff)),
            run_time=0.6,
        )


# -----------------------------------------------------------------------------
# 7b. Real-world: Model-View-Projection (3D)
# -----------------------------------------------------------------------------


class MVPDemo(ThreeDScene):
    """A 3D walk-through of *Model · View · Projection* — the matrix chain
    every graphics pipeline applies to every vertex.  We use a small cube as
    the model and apply the same primitives our ``Transform3D`` benchmark
    uses (``scale``, ``rotateX/Y/Z``, ``transform``) so the audience sees
    *what those matrices actually do*.

    Everything is animated against a real ``ThreeDAxes`` so the viewer can
    follow the cube's journey from local → world → view → screen.
    """

    def construct(self):
        bench_lead = Text(
            "Our benchmark: a 3-D Model · View · Projection pipeline.",
            font_size=28, weight=BOLD, color=ORANGE,
        )
        bench_sub = Text(
            "It's the matrix chain every graphics renderer applies to every vertex —\n"
            "a perfect stress test for dynamic staging.",
            font_size=22, color=GREY_B,
        ).next_to(bench_lead, DOWN, buff=0.3)
        bench_grp = VGroup(bench_lead, bench_sub).move_to(ORIGIN)

        bench_sub.set_opacity(0)
        self.add_fixed_in_frame_mobjects(bench_lead, bench_sub)
        self.play(FadeIn(bench_lead))
        self.play(bench_sub.animate.set_opacity(1))
        self.wait(2.5)
        self.play(FadeOut(bench_grp))
        self.remove(bench_lead, bench_sub)

        # ----- Fixed-in-frame title strip ------------------------------------
        head = Text("Model · View · Projection",
                    weight=BOLD, font_size=42)
        head.to_edge(UP)
        sub = Text(
            "Every frame: thousands of vertices flow through "
            "Model → View → Projection.",
            font_size=20, color=GREY_B,
        ).next_to(head, DOWN, buff=0.18)
        self.add_fixed_in_frame_mobjects(head, sub)
        self.play(FadeIn(head), FadeIn(sub))

        # ----- 3D axes --------------------------------------------------------
        axes = ThreeDAxes(
            x_range=[-4, 4, 1], y_range=[-4, 4, 1], z_range=[-3, 3, 1],
            x_length=6, y_length=6, z_length=4.5,
        )
        x_lbl = axes.get_x_axis_label("x", edge=RIGHT, direction=RIGHT)
        y_lbl = axes.get_y_axis_label("y", edge=UP,    direction=UP)
        z_lbl = axes.get_z_axis_label("z", edge=OUT,   direction=OUT)
        self.set_camera_orientation(phi=68 * DEGREES, theta=-50 * DEGREES,
                                    distance=10)
        self.play(Create(axes), FadeIn(VGroup(x_lbl, y_lbl, z_lbl)))

        # ----- Status banner shown in the upper-left corner ------------------
        stage_box = Rectangle(width=4.6, height=0.55, stroke_color=YELLOW_E,
                              stroke_width=2, fill_color=BLACK,
                              fill_opacity=0.6).to_corner(UL).shift(DOWN * 1.0)
        stage_lbl = Text("Stage:", font_size=20, color=GREY_B)
        stage_val = Text("local space", font_size=22, color=BLUE_C, weight=BOLD)
        VGroup(stage_lbl, stage_val).arrange(RIGHT, buff=0.2).move_to(
            stage_box.get_center())
        self.add_fixed_in_frame_mobjects(stage_box, stage_lbl, stage_val)
        self.play(FadeIn(stage_box), FadeIn(stage_lbl), FadeIn(stage_val))

        caption_holder = {"caption": None}

        def show_caption(text, color):
            new = Text(text, font_size=20, color=color).to_edge(
                DOWN, buff=0.45)
            self.add_fixed_in_frame_mobjects(new)
            anims = [FadeIn(new)]
            if caption_holder["caption"] is not None:
                anims.insert(0, FadeOut(caption_holder["caption"]))
            self.play(*anims, run_time=0.5)
            caption_holder["caption"] = new

        def set_stage(text, color):
            new = Text(text, font_size=22, color=color, weight=BOLD)
            new.move_to(stage_val.get_center()).align_to(stage_val, LEFT)
            self.add_fixed_in_frame_mobjects(new)
            self.play(FadeOut(stage_val), FadeIn(new), run_time=0.5)
            return new

        # =====================================================================
        # MODEL  M = T · Rz · Ry · Rx · S    (object → world)
        # =====================================================================
        show_caption("Model: place a local mesh into the world.", BLUE_C)

        cube = Cube(side_length=1.0, fill_color=BLUE_C, fill_opacity=0.55,
                    stroke_color=WHITE, stroke_width=1.2)
        cube.move_to(axes.c2p(0, 0, 0))
        self.play(FadeIn(cube))
        self.wait(0.4)

        show_caption("scale(0.9, 1.6, 0.7) — stretch along each axis", BLUE_C)
        S = np.diag([0.9, 1.6, 0.7])
        self.play(ApplyMatrix(S, cube), run_time=1.4)
        self.wait(0.3)

        show_caption("rotateX(45°) — pitch around the x-axis", BLUE_C)
        self.play(Rotate(cube, angle=PI / 4, axis=RIGHT,
                         about_point=axes.c2p(0, 0, 0)), run_time=1.3)
        self.wait(0.2)

        show_caption("rotateY(35°) — yaw around the y-axis", BLUE_C)
        self.play(Rotate(cube, angle=35 * DEGREES, axis=UP,
                         about_point=axes.c2p(0, 0, 0)), run_time=1.3)
        self.wait(0.2)

        show_caption("rotateZ(20°) — roll around the z-axis", BLUE_C)
        self.play(Rotate(cube, angle=20 * DEGREES, axis=OUT,
                         about_point=axes.c2p(0, 0, 0)), run_time=1.1)
        self.wait(0.2)

        show_caption(
            "transform(2, 1, 0.5) — translate to its world position",
            BLUE_C,
        )
        target = axes.c2p(2, 1, 0.5)
        self.play(cube.animate.shift(target - axes.c2p(0, 0, 0)),
                  run_time=1.3)
        self.wait(0.4)

        stage_val = set_stage("world space", GREEN_D)

        show_caption(
            "View: rotate the world so the camera sits at the origin, "
            "looking down −z.",
            GREEN_D,
        )

        cam = Cone(base_radius=0.35, height=0.7,
                   fill_color=YELLOW_E, fill_opacity=0.8,
                   stroke_color=YELLOW_E)
        cam.rotate(PI / 2, axis=RIGHT)  # point along -y
        cam.move_to(axes.c2p(0, -3.5, 0.5))
        cam_lbl = Text("camera", font_size=16, color=YELLOW_E)
        self.add_fixed_in_frame_mobjects(cam_lbl)
        cam_lbl.to_corner(UR).shift(DOWN * 1.0)
        self.play(FadeIn(cam), FadeIn(cam_lbl))
        self.wait(0.3)

        self.move_camera(phi=80 * DEGREES, theta=-90 * DEGREES,
                         run_time=2.0)
        self.wait(0.4)

        stage_val = set_stage("camera space", YELLOW_E)

        # =====================================================================
        # PROJECTION  P  (camera → screen)
        # =====================================================================
        show_caption(
            "Projection: collapse the depth axis so 3D becomes 2D pixels.",
            YELLOW_E,
        )

        world = VGroup(axes, x_lbl, y_lbl, z_lbl, cube, cam)
        flatten = np.diag([1.0, 1.0, 0.001])
        # First swing to a near-side view so z is visibly vertical on screen.
        self.move_camera(phi=85 * DEGREES, theta=-90 * DEGREES, run_time=1.2)
        # Now visibly squish the world flat into the xy-plane.
        self.play(ApplyMatrix(flatten, world), run_time=1.6)
        self.wait(0.3)
        # Finally rotate up to look head-on at the resulting 2-D plane.
        self.move_camera(phi=0 * DEGREES, theta=-90 * DEGREES, run_time=1.2)
        self.wait(0.4)

        stage_val = set_stage("screen space", RED_C)
        self.wait(0.6)

        # =====================================================================
        # Reveal the pipeline name in the centre of the (now flat) frame.
        # Hide the (now-flattened) 3-D world first so it doesn't sit behind
        # the title as visual noise.
        # =====================================================================
        mvp_title = Text(
            "Model · View · Projection",
            weight=BOLD, font_size=64, color=YELLOW,
        )
        self.add_fixed_in_frame_mobjects(mvp_title)
        self.play(
            FadeOut(VGroup(axes, x_lbl, y_lbl, z_lbl, cube, cam)),
            FadeOut(head), FadeOut(sub),
            FadeIn(mvp_title, scale=0.9),
            run_time=0.9,
        )
        self.wait(1.5)

        show_caption(
            "When M, V, P are fixed, staging fuses the chain "
            "into a few multiply-adds per vertex.",
            YELLOW,
        )
        self.wait(2.5)

        self.play(
            FadeOut(VGroup(stage_box, stage_lbl, stage_val, cam_lbl)),
            FadeOut(mvp_title),
            FadeOut(caption_holder["caption"]),
            run_time=0.8,
        )
        caption_holder["caption"] = None

        teaser_lbl = Text(
            "What dynamic staging produces:", font_size=22, color=GREY_B,
        )
        before_code = mls(
            "fun project(v) =\n"
            "  multiply(P, multiply(V, multiply(M, v)))"
        ).scale(0.6)
        arrow = Arrow(LEFT * 1.0, RIGHT * 1.0, buff=0.0,
                      color=YELLOW_E, stroke_width=4)
        arrow_lbl = Text("staging", font_size=18, color=YELLOW_E)
        arrow_lbl.next_to(arrow, UP, buff=0.08)
        # A representative residual: just a handful of multiply-adds.
        after_code = mls(
            "fun project(v) =\n"
            "  [a00*v.0 + a01*v.1 + a02*v.2 + a03,\n"
            "   a10*v.0 + a11*v.1 + a12*v.2 + a13,\n"
            "   a20*v.0 + a21*v.1 + a22*v.2 + a23]"
        ).scale(0.55)

        before_grp = VGroup(
            Text("Original", font_size=16, color=GREY_B), before_code,
        ).arrange(DOWN, buff=0.15)
        after_grp = VGroup(
            Text("Specialized", font_size=16, color=GREEN_D), after_code,
        ).arrange(DOWN, buff=0.15)

        teaser = VGroup(
            before_grp,
            VGroup(arrow_lbl, arrow).arrange(DOWN, buff=0.05),
            after_grp,
        ).arrange(RIGHT, buff=0.5).move_to(ORIGIN).shift(DOWN * 0.2)

        teaser_lbl.next_to(teaser, UP, buff=0.4)

        arrow.set_opacity(0)
        arrow_lbl.set_opacity(0)
        after_grp.set_opacity(0)

        self.add_fixed_in_frame_mobjects(teaser_lbl, teaser)
        self.play(FadeIn(teaser_lbl), FadeIn(before_grp))
        self.wait(0.4)
        self.play(
            arrow.animate.set_opacity(1),
            arrow_lbl.animate.set_opacity(1),
        )
        self.play(after_grp.animate.set_opacity(1))
        self.wait(3.5)

        # Cleanup.
        self.play(FadeOut(VGroup(teaser_lbl, teaser)))


# -----------------------------------------------------------------------------
# 8. Closing
# -----------------------------------------------------------------------------


class Closing(Scene):
    def construct(self):
        line1 = Text("Dynamic Staging", weight=BOLD, font_size=56)
        line2 = Text(
            "high-level code, low-level performance, by one keyword.",
            font_size=26,
            slant=ITALIC,
            color=GREY_B,
        )
        headline = VGroup(line1, line2).arrange(DOWN, buff=0.3)
        headline.to_edge(UP, buff=1.0)

        self.play(FadeIn(line1, shift=UP * 0.2))
        self.play(FadeIn(line2))
        self.wait(0.6)

        try_lbl = Text(
            "Try it out in your browser:",
            font_size=30, weight=BOLD, color=YELLOW,
        )
        url = Text(
            "chinglongtin.github.io/mlscript",
            font="Menlo", font_size=28, color=BLUE_C,
        )

        try:
            qr = ImageMobject("../qrcode.png").scale_to_fit_height(2.6)
        except Exception:
            qr = Square(side_length=2.6, color=GREY_B)

        cta = Group(try_lbl, qr, url).arrange(DOWN, buff=0.3)
        cta.next_to(headline, DOWN, buff=0.6)

        self.play(FadeIn(try_lbl))
        self.play(FadeIn(qr, scale=0.85))
        self.play(FadeIn(url))

        thanks = Text("Thank you!", font_size=34, color=YELLOW).to_edge(
            DOWN, buff=0.5)
        self.play(FadeIn(thanks, scale=0.85))
        self.wait(4.0)


# -----------------------------------------------------------------------------
# Master scene — concatenates every segment into one ~3 minute video.
# -----------------------------------------------------------------------------

class FinalVideo(ThreeDScene):
    """Render the full ~3 minute video in one go.

    Inherits from ThreeDScene (not Scene) so that MVPDemo's 3D camera
    calls — `add_fixed_in_frame_mobjects`, `set_camera_orientation`,
    `move_camera` — resolve when its `construct` body is run inline here.
    A ThreeDScene behaves like a regular Scene for all the 2D segments.
    """

    def construct(self):
        for cls in (
            TitleCard,
            Motivation,
            MSPApproach,
            OurApproach,
            PowExample,
            Novelty,
            MVPDemo,
            Benchmarks,
            Closing,
        ):
            cls.construct(self)
