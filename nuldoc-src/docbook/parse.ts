import { parseXmlFile } from "../xml.ts";
import { DocBookError, XmlParseError } from "../errors.ts";
import { createNewDocumentFromRootElement, Document } from "./document.ts";
import toHtml from "./to_html.ts";

export async function parseDocBookFile(filePath: string): Promise<Document> {
  try {
    const root = await parseXmlFile(filePath);
    const doc = createNewDocumentFromRootElement(root, filePath);
    return toHtml(doc);
  } catch (e) {
    if (e instanceof DocBookError || e instanceof XmlParseError) {
      e.message = `${e.message} in ${filePath}`;
    }
    throw e;
  }
}
