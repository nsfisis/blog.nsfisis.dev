import { Document } from "./document.ts";
import { DocBookError } from "../errors.ts";
import {
  Element,
  findFirstChildElement,
  forEachChild,
  forEachChildRecursively,
  Node,
  removeChildElements,
} from "../dom.ts";

export default function toHtml(doc: Document): Document {
  removeArticleInfo(doc);
  removeArticleAttributes(doc);
  removeUnnecessaryTextNode(doc);
  transformElementNames(doc, "emphasis", "em");
  transformElementNames(doc, "informaltable", "table");
  transformElementNames(doc, "itemizedlist", "ul");
  transformElementNames(doc, "link", "a");
  transformElementNames(doc, "listitem", "li");
  transformElementNames(doc, "literal", "code");
  transformElementNames(doc, "orderedlist", "ol");
  transformElementNames(doc, "simpara", "p");
  transformAttributeNames(doc, "xml:id", "id");
  transformSectionIdAttribute(doc);
  setSectionTitleAnchor(doc);
  transformSectionTitleElement(doc);
  transformProgramListingElement(doc);
  transformLiteralLayoutElement(doc);
  replaceDocumentTitleParentheses(doc);
  setDefaultLangAttribute(doc);
  return doc;
}

function removeArticleInfo(doc: Document) {
  const article = findFirstChildElement(doc.root, "article");
  if (!article) {
    throw new DocBookError(
      `[docbook.tohtml] <article> element not found`,
    );
  }
  removeChildElements(article, "info");
}

function removeArticleAttributes(doc: Document) {
  const article = findFirstChildElement(doc.root, "article");
  if (!article) {
    throw new DocBookError(
      `[docbook.tohtml] <article> element not found`,
    );
  }
  article.attributes.delete("xmlns");
  article.attributes.delete("xmlns:xl");
  article.attributes.delete("version");
}

function removeUnnecessaryTextNode(doc: Document) {
  const g = (n: Node) => {
    if (n.kind !== "element") {
      return;
    }

    let changed = true;
    while (changed) {
      changed = false;
      if (n.children.length === 0) {
        break;
      }
      const firstChild = n.children[0];
      if (firstChild.kind === "text" && firstChild.content.trim() === "") {
        n.children.shift();
        changed = true;
      }
      if (n.children.length === 0) {
        break;
      }
      const lastChild = n.children[n.children.length - 1];
      if (lastChild.kind === "text" && lastChild.content.trim() === "") {
        n.children.pop();
        changed = true;
      }
    }

    forEachChild(n, g);
  };
  forEachChild(doc.root, g);
}

function transformElementNames(
  doc: Document,
  from: string,
  to: string,
) {
  forEachChildRecursively(doc.root, (n) => {
    if (n.kind === "element" && n.name === from) {
      n.name = to;
    }
  });
}

function transformAttributeNames(
  doc: Document,
  from: string,
  to: string,
) {
  forEachChildRecursively(doc.root, (n) => {
    if (n.kind !== "element") {
      return;
    }
    const value = n.attributes.get(from) as string;
    if (value !== undefined) {
      n.attributes.delete(from);
      n.attributes.set(to, value);
    }
  });
}

function transformSectionIdAttribute(doc: Document) {
  forEachChildRecursively(doc.root, (n) => {
    if (n.kind !== "element" || n.name !== "section") {
      return;
    }

    const idAttr = n.attributes.get("id");
    n.attributes.set("id", `section--${idAttr}`);
  });
}

function setSectionTitleAnchor(doc: Document) {
  const sectionStack: Element[] = [];
  const g = (c: Node) => {
    if (c.kind !== "element") {
      return;
    }

    if (c.name === "section") {
      sectionStack.push(c);
    }
    forEachChild(c, g);
    if (c.name === "section") {
      sectionStack.pop();
    }
    if (c.name === "title") {
      const currentSection = sectionStack[sectionStack.length - 1];
      if (!currentSection) {
        throw new DocBookError(
          "[docbook.tohtml] <title> element must be inside <section>",
        );
      }
      const sectionId = currentSection.attributes.get("id");
      const aElement: Element = {
        kind: "element",
        name: "a",
        attributes: new Map(),
        children: c.children,
      };
      aElement.attributes.set("href", `#${sectionId}`);
      c.children = [aElement];
    }
  };
  forEachChild(doc.root, g);
}

function transformSectionTitleElement(doc: Document) {
  let sectionLevel = 1;
  const g = (c: Node) => {
    if (c.kind !== "element") {
      return;
    }

    if (c.name === "section") {
      sectionLevel += 1;
      c.attributes.set("--section-level", sectionLevel.toString());
    }
    forEachChild(c, g);
    if (c.name === "section") {
      sectionLevel -= 1;
    }
    if (c.name === "title") {
      c.name = `h${sectionLevel}`;
    }
  };
  forEachChild(doc.root, g);
}

function transformProgramListingElement(doc: Document) {
  forEachChildRecursively(doc.root, (n) => {
    if (n.kind !== "element" || n.name !== "programlisting") {
      return;
    }

    n.name = "pre";
    const codeElement: Element = {
      kind: "element",
      name: "code",
      attributes: new Map(),
      children: n.children,
    };
    n.children = [codeElement];
  });
}

function transformLiteralLayoutElement(doc: Document) {
  forEachChildRecursively(doc.root, (n) => {
    if (n.kind !== "element" || n.name !== "literallayout") {
      return;
    }

    n.name = "pre";
    const children = n.children;
    const codeElement: Element = {
      kind: "element",
      name: "code",
      attributes: new Map(),
      children: children,
    };
    n.children = [codeElement];
  });
}

function replaceDocumentTitleParentheses(doc: Document) {
  doc.title.replaceAll(/\[(.+?)\] ?/g, "【$1】");
}

function setDefaultLangAttribute(_doc: Document) {
  // TODO
  // if (!e.attributes.has("lang")) {
  //   e.attributes.set("lang", "ja-JP");
  // }
}
