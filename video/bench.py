from manim import *


class BenchTime(Scene):
    def construct(self):
        title_time = Title("Benchmark: Model-View-Transform")
        chart = BarChart(
            values=[0.55, 1.46],
            bar_names=["staged", "non-staged"],
            bar_colors=["orange", "blue"],
            y_range=[0, 2, 1],
            y_length=4,
            x_length=10,
            x_axis_config={"font_size": 36},
            y_axis_config={"decimal_number_config": {"unit": "s"}},
        )

        c_bar_lbls = chart.get_bar_labels(font_size=48)

        self.add(chart)
        self.add(title_time)

        chart2 = BarChart(
            values=[975, 242],
            bar_names=["staged", "non-staged"],
            bar_colors=["orange", "blue"],
            y_range=[0, 1000, 200],
            y_length=4,
            x_length=10,
            x_axis_config={"font_size": 36},
            y_axis_config={
                "decimal_number_config": {"unit": "MB", "num_decimal_places": 0}
            },
        )

        c_bar_lbls = chart.get_bar_labels(font_size=48)
        c_bar_lbls2 = chart2.get_bar_labels(font_size=48)
        self.add(c_bar_lbls)

        self.play(
            ReplacementTransform(chart, chart2),
            ReplacementTransform(c_bar_lbls, c_bar_lbls2),
        )
