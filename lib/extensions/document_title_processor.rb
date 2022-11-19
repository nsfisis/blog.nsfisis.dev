module Nuldoc
  module Extensions
    class DocumentTitleProcessor < Asciidoctor::Extensions::TreeProcessor
      def process(doc)
        doc.title = substitute_document_title(doc.title)
      end

      private

      def substitute_document_title(title)
        title.sub(/\A\[(.+?)\] /, '【\1】')
      end
    end
  end
end
