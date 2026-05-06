from manim import *


class Bib(Scene):
    def construct(self):
        refs = Tex(
            r"""\raggedright{Walid Taha. A gentle introduction to multi-stage programming. In \textit{Domain-Specific Program Generation: International Seminar, Dagstuhl Castle, Germany, March 23-28, 2003. Revised Papers}, pages 30–50. Springer, 2004.}
            \\ \vspace{1em}
            \raggedright{Kedar Swadi, Walid Taha, Oleg Kiselyov, and Emir Pasalic. A monadic approach for avoiding code duplication when staging memoized functions. In \textit{Proceedings of the 2006 ACM SIGPLAN symposium on Partial evaluation and semantics-based program manipulation}, pages 160–169, 2006.}
            \\ \vspace{1em}
            \raggedright{A. Shali and W. R. Cook, “Hybrid partial evaluation,” in \textit{Proceedings of the 2011 ACM international conference on Object oriented programming systems languages and applications}, 2011, pp. 375–390.}
            """
        )

        self.add(refs.scale(0.6))
