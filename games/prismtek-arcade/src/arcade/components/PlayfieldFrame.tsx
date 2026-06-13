import { createElement, type ReactNode } from "react";

type PlayfieldFrameProps = {
  title: string;
  score: number;
  personalBest: number | null;
  children: ReactNode;
  meta?: ReactNode;
};

export function PlayfieldFrame({ title, score, personalBest, children, meta }: PlayfieldFrameProps) {
  return createElement(
    "section",
    { className: "playfield-frame" },
    createElement(
      "header",
      { className: "playfield-header" },
      createElement("div", null, createElement("p", { className: "eyebrow" }, "Prismtek Arcade"), createElement("h2", null, title)),
      createElement("div", { className: "score-card" }, createElement("span", null, "Score"), createElement("strong", null, score), createElement("small", null, `Best ${personalBest ?? 0}`))
    ),
    createElement("div", { className: "canvas-wrap" }, children),
    meta ? createElement("footer", { className: "playfield-meta" }, meta) : null
  );
}
