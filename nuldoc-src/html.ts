import { Document } from "./docbook/document.ts";
import { Element, forEachChild, Node, Text } from "./dom.ts";
import { DocBookError } from "./errors.ts";

export function writeHtmlFile(dom: Document, _filePath: string) {
  console.log(toHtmlText(dom));
}

type Context = {
  indentLevel: number;
};

type Dtd = { type: "block" | "inline"; auto_closing?: boolean };

function getDtd(name: string): Dtd {
  switch (name) {
    case "__root__":
      return { type: "block" };
    case "a":
      return { type: "inline" };
    case "em":
      return { type: "inline" };
    case "article":
      return { type: "block" };
    case "blockquote":
      return { type: "block" };
    case "pre":
      return { type: "block" };
    case "ul":
      return { type: "block" };
    case "ol":
      return { type: "block" };
    case "br":
      return { type: "block", auto_closing: true };
    case "li":
      return { type: "block" };
    case "code":
      return { type: "block" };
    case "hr":
      return { type: "block" };
    case "h1":
      return { type: "block" }; // TODO
    case "h2":
      return { type: "block" }; // TODO
    case "h3":
      return { type: "block" }; // TODO
    case "h4":
      return { type: "block" }; // TODO
    case "h5":
      return { type: "block" }; // TODO
    case "h6":
      return { type: "block" }; // TODO
    case "p":
      return { type: "block" };
    case "table":
      return { type: "block" };
    case "thead":
      return { type: "block" };
    case "tfoot":
      return { type: "block" };
    case "tbody":
      return { type: "block" };
    case "tr":
      return { type: "block" };
    case "td":
      return { type: "block" }; // TODO
    case "section":
      return { type: "block" };
    default:
      throw new DocBookError(`[html.write] Unknown element name: ${name}`);
  }
}

function toHtmlText(dom: Document): string {
  return nodeToHtmlText(dom.root, {
    indentLevel: -1,
  });
}

function nodeToHtmlText(n: Node, ctx: Context): string {
  if (n.kind === "text") {
    return textNodeToHtmlText(n, ctx);
  } else {
    return elementNodeToHtmlText(n, ctx);
  }
}

function textNodeToHtmlText(t: Text, _ctx: Context): string {
  if (t.content.trim() === "") return "";

  // 日本語で改行するときはスペースを入れない
  return t.content.trim().replaceAll(/\n */g, " ");
}

function elementNodeToHtmlText(e: Element, ctx: Context): string {
  const dtd = getDtd(e.name);

  let s = "";
  if (e.name !== "__root__") {
    if (dtd.type === "block") {
      s += indent(ctx);
    }
    s += `<${e.name}`;
    const attributes = getElementAttributes(e);
    if (attributes.length > 0) {
      s += " ";
      for (let i = 0; i < attributes.length; i++) {
        const [name, value] = attributes[i];
        s += `${name}="${value}"`;
        if (i !== attributes.length - 1) {
          s += " ";
        }
      }
    }
    s += ">";
    if (dtd.type === "block") {
      s += "\n";
    }
  }
  ctx.indentLevel += 1;
  if (dtd.type === "block" && e.children.length > 0) {
    const firstChild = e.children[0];
    const needsIndent = firstChild.kind === "text" ||
      getDtd(firstChild.name).type === "inline";
    if (needsIndent) {
      s += indent(ctx);
    }
  }
  forEachChild(e, (c) => {
    s += nodeToHtmlText(c, ctx);
  });
  ctx.indentLevel -= 1;
  if (e.name !== "__root__" && !dtd.auto_closing) {
    if (dtd.type === "block") {
      if (e.children.length > 0) {
        const lastChild = e.children[e.children.length - 1];
        const needsLineBreak = lastChild.kind === "text" ||
          getDtd(lastChild.name).type === "inline";
        if (needsLineBreak) {
          s += "\n";
        }
      }
      s += indent(ctx);
    }
    s += `</${e.name}>`;
    if (dtd.type === "block") {
      s += "\n";
    }
  }
  return s;
}

function indent(ctx: Context): string {
  return "  ".repeat(ctx.indentLevel);
}

function getElementAttributes(e: Element): [string, string][] {
  return [...e.attributes.entries()]
    .filter((a) => !a[0].startsWith("--"))
    .sort(
      (a, b) => {
        if (a[0] > b[0]) return 1;
        else if (a[0] < b[0]) return -1;
        else return 0;
      },
    );
}
