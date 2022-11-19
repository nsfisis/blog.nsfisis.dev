module Nuldoc
  module Extensions
    class TagsProcessor < Asciidoctor::Extensions::TreeProcessor
      def process(doc)
        doc.attributes['tags'] = convert_tags(doc.attributes['tags'])
      end

      private

      def convert_tags(tags)
        return [] unless tags

        tags
          .split(',')
          .map(&:strip)
          .map { Tag.from_slug(_1) }
      end
    end
  end
end
