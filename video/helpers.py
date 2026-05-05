from manim import *


def mls(code, **kwargs):
    return Code(
        code_string=code,
        add_line_numbers=False,
        language="javascript",
        tab_width=2,
        formatter_style="emacs",
        paragraph_config={"line_spacing": 1},
        **kwargs,
    )


def highlight(section):
    return SurroundingRectangle(section).set_fill(YELLOW).set_opacity(0.3)
