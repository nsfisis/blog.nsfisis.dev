module Nuldoc
  module Extensions
    class SourceIdProcessor < Asciidoctor::Extensions::TreeProcessor
      def process(doc)
        errors = []
        (doc.find_by(context: :listing) {_1.style == 'source'}).each do |source|
          source.id = "source.#{source.id}"
        end
      end
    end
  end
end
