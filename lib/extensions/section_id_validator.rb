module Nuldoc
  module Extensions
    class SectionIdValidator < Asciidoctor::Extensions::TreeProcessor
      def process(doc)
        errors = []
        (doc.find_by(context: :section) {_1.level > 0}).each do |section|
          errors << validate_section(section)
        end
        error_message = errors.compact.join("\n")
        unless error_message.empty?
          raise "SectionIdValidator (#{doc.attributes['source-file-path']}):\n#{error_message}"
        end
      end

      private

      def validate_section(section)
        id = section.id
        unless id
          return "Section '#{section.title}': each section MUST have an id."
        end
        unless id.match?(/\A[-0-9a-z]+\z/)
          return "Section '#{section.title}' (##{id}): section id MUST consist of either hyphen, digits or lowercases."
        end
        nil
      end
    end
  end
end
