module NulDoc
  class HTMLConverter < (Asciidoctor::Converter.for 'html5')
    register_for 'html5'

    def initialize(backend, opts)
      super
      @template_dir = opts[:template_dirs].first
    end

    def convert_document(node)
      template_file_name = "document__#{node.attr('document-type')}.html.erb"
      erb = Tilt::ERBTemplate.new("#{@template_dir}/#{template_file_name}")
      erb.render(node, {})
    end
  end
end
