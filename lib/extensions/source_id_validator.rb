module Nuldoc
  module Extensions
    class SourceIdValidator < Asciidoctor::Extensions::TreeProcessor
      def process(doc)
        errors = []
        (doc.find_by(context: :listing) {_1.style == 'source'}).each do |source|
          errors << validate_section(source)
        end
        error_message = errors.compact.join("\n")
        unless error_message.empty?
          raise "SourceIdValidator (#{doc.attributes['source-file-path']}):\n#{error_message}"
        end
      end

      private

      def validate_section(source)
        id = source.id
        unless id
          return "Each source MUST have an id."
        end
        if id.start_with?('source.')
          return "Source id (##{id}) MUST NOT start with 'source.', which is appended by `nul`."
        end
        unless id.match?(/\A[-0-9a-z]+\z/)
          return "Source id (##{id}) MUST consist of either hypen, digits or lowercases."
        end
        nil
      end
    end
  end
end
