module NulDoc
  class Parser
    def initialize(common_attributes, content_dir, template_dir)
      @common_attributes = common_attributes
      @content_dir = content_dir
      @template_dir = template_dir
    end

    def parse_file(file_path, document_type)
      Asciidoctor.load_file(
        file_path,
        backend: :html5,
        doctype: :article,
        standalone: true,
        safe: :unsafe,
        template_dirs: [@template_dir],
        template_engine: 'erb',
        template_engine_options: { erb: { trim: '<>' } },
        attributes: @common_attributes.merge({
          'document-type' => document_type,
          'source-file-path' => file_path,
          'href' => file_path.sub(@content_dir, '').sub('.adoc', '/'),
          'source-highlighter' => 'rouge',
          'reproducible' => true,
          'sectids' => false,
        }),
        extension_registry: Asciidoctor::Extensions.create do
          tree_processor Nuldoc::Extensions::RevisionHistoryProcessor
          tree_processor Nuldoc::Extensions::DocumentTitleProcessor
          tree_processor Nuldoc::Extensions::LangAttributeProcessor
          # tree_processor Nuldoc::Extensions::SectionIdValidator
          # tree_processor Nuldoc::Extensions::SourceIdValidator
          tree_processor Nuldoc::Extensions::TagsProcessor

          # MUST BE AT THE END
          tree_processor Nuldoc::Extensions::SourceIdProcessor
        end,
      )
    end

    def parse_string(s, copyright_year)
      Asciidoctor.convert(
        s,
        backend: :html5,
        doctype: :article,
        safe: :unsafe,
        template_dirs: [@template_dir],
        template_engine: 'erb',
        attributes: @common_attributes.merge({
          'copyright-year' => copyright_year,
        }),
        extension_registry: Asciidoctor::Extensions.create do
          tree_processor Nuldoc::Extensions::LangAttributeProcessor
          tree_processor Nuldoc::Extensions::TagsProcessor
        end,
      )
    end
  end
end
