from manim import *


def mls(code):
    return Code(
        code_string=code,
        add_line_numbers=False,
        language="javascript",
        tab_width=2,
        formatter_style="emacs",
        paragraph_config={"line_spacing": 1},
    )


power_base = """
module M with
  fun pow(n, x) = if n is
    0 then 1
    else x * pow(n - 1, x)"""

power_msp = """
module M with
  fun pow(n, x) = if n is
    0 then .<1>.
    else .<.~x * .~(pow(n-1, x))>."""

power_staged = """
staged module M with
  fun pow(n, x) = if n is
    0 then 1
    else x * pow(n - 1, x)"""


class MSPAnnotation(Scene):
    def construct(self):
        before = mls(power_base)
        after = mls(power_msp)
        self.play(FadeTransform(before, after))
        lines = after.code_lines
        relevant = [
            lines[2][5:7],
            lines[2][-2:],
            lines[3][4 : 4 + 4],
            lines[3][10:13],
            lines[3][-3:],
        ]
        # map(function x: SurroundingRectangle(x).set_fill(YELLOW).set_opacity(0), relevant)
        annot_highlights = VGroup(
            list(
                map(
                    lambda x: SurroundingRectangle(x, buff=0)
                    .set_fill(YELLOW)
                    .set_opacity(0),
                    relevant,
                )
            )
        )
        self.add(annot_highlights)
        self.play(annot_highlights.animate.set_opacity(0.3))


class StagedAnnotation(Scene):
    def construct(self):
        rendered_code = mls(power_base)
        rendered_code2 = mls(power_staged)

        self.play(FadeTransform(rendered_code, rendered_code2))
        staged_highlight = (
            # highlights "staged" keyword
            SurroundingRectangle(rendered_code2.code_lines[0][0:6])
            .set_fill(YELLOW)
            .set_opacity(0)
        )
        self.add(staged_highlight)
        self.play(staged_highlight.animate.set_opacity(0.3))


# class TitleExample(Scene):
#     def construct(self):
#         title = Title(f"Reflection of Intermediate Representation")
#         self.add(title)
#         pass

# Source - https://stackoverflow.com/q/76197478
# Posted by Maluyelang
# Retrieved 2026-05-04, License - CC BY-SA 4.0


class CodeTrackingAnimation(Scene):
    def construct(self):
        code_str = """
        module M with
          fun pow(n, x) = if n is
            0 then 1
            else x * pow(n - 1, x)"""
        code = self.build_code_block(code_str)
        for i in range(len(self.sliding_wins) - 1):
            self.highlight(i, i + 1)

    def build_code_block(self, code_str):
        from manim.mobject.text.text_mobject import remove_invisible_chars

        # print(Code.get_styles_list())
        # build the code block
        code = mls(code_str)
        code.code_lines = remove_invisible_chars(code.code_lines)
        self.add(code)
        # build sliding windows (SurroundingRectangle)
        self.sliding_wins = VGroup()
        height = code.code_lines[0].height
        # Source - https://stackoverflow.com/a/76198843
        # Posted by JLDiaz, modified by community. See post 'Timeline' for change history
        # Retrieved 2026-05-04, License - CC BY-SA 4.0
        # for line in code.code_lines:
        #     self.sliding_wins.add(
        #         SurroundingRectangle(line)
        #         .set_fill(YELLOW)
        #         .set_opacity(0)
        #         .stretch_to_fit_width(code.background.width)
        #         .align_to(code.background, LEFT)
        #     )
        # print(vars(code.code_lines[1]))
        for l in range(5):
            self.sliding_wins.add(
                SurroundingRectangle(code.code_lines[1][l])
                .set_fill(YELLOW)
                .set_opacity(0)
            )

        self.add(self.sliding_wins)
        return code

    def highlight(self, prev_line, line):
        time = 0.3
        self.play(self.sliding_wins[prev_line].animate.set_opacity(0.3), run_time=time)
        # self.sliding_wins[line].set_opacity(0.3)
        self.play(
            Transform(
                self.sliding_wins[prev_line],
                self.sliding_wins[line],
            ),
            run_time=time,
        )
