module Nuldoc
  module Extensions
    class LangAttributeProcessor < Asciidoctor::Extensions::TreeProcessor
      def process(doc)
        doc.attributes['lang'] ||= 'ja-JP'
      end
    end
  end
end
