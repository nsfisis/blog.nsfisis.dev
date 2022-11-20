module NulDoc
  class Command
    def initialize(config)
      @config = config
      @content_dir = @config[:content_dir]
      @dest_dir = @config[:dest_dir]
      @static_dir = @config[:static_dir]
      @template_dir = @config[:template_dir]
      @parser = NulDoc::Parser.new(
        {
          'stylesheets' => stylesheets,
          'author' => @config[:author],
          'site-copyright-year' => @config[:site_copyright_year],
          'site-name' => @config[:site_name],
        },
        @content_dir,
        @template_dir,
      )
    end

    def run
      posts = generate_posts(@content_dir + '/posts')
      generate_tags(posts)
      generate_post_list(posts)
    end

    private

    def generate_posts(source_dir)
      post_files = collect_post_files(source_dir)
      posts = parse_posts(post_files)
      output_posts(posts)
      posts
    end

    def collect_post_files(source_dir)
      file_paths = []
      Dir.glob('**/*.adoc', base: source_dir, sort: true) do |path|
        file_paths << "#{source_dir}/#{path}"
      end
      file_paths
    end

    def parse_posts(post_file_paths)
      post_file_paths.map { @parser.parse_file(_1, 'post') }
    end

    def output_posts(posts)
      posts.each do |post|
        destination_file_path = post.attributes['source-file-path']
          .sub(@content_dir, @dest_dir)
          .sub('.adoc', '/index.html')
        destination_dir = File.dirname(destination_file_path)
        unless Dir.exist?(destination_dir)
          FileUtils.makedirs(destination_dir)
        end
        open(destination_file_path, 'w') do |f|
          f.puts(post.convert)
        end
      end
    end

    def generate_tags(posts)
      tags_and_posts = collect_tags(posts)
      tag_docs = build_tag_docs(tags_and_posts)
      output_tags(tag_docs)
    end

    def collect_tags(posts)
      tags_and_posts = {}
      posts.each do |post|
        post.attributes['tags'].each do |tag|
          tags_and_posts[tag] ||= []
          tags_and_posts[tag] << post
        end
      end
      tags_and_posts
        .transform_values {|posts|
          posts.sort_by {|post|
            post.attributes['revision-history'].first.date # created_at
          }.reverse
        }
        .sort_by {|tag, _| tag.slug }
        .to_h
    end

    def build_tag_docs(tags_and_posts)
      tags_and_posts.map do |tag, posts|
        [tag, build_tag_doc(tag, posts)]
      end
    end

    def build_tag_doc(tag, posts)
      converter = NulDoc::HTMLConverter.new(nil, { template_dirs: [@template_dir] })
      converter.convert_document(
        (Class.new do
          def initialize(config, tag, posts, stylesheets)
            @config = config
            @tag = tag
            @posts = posts
            @stylesheets = stylesheets
          end
          def attr(name)
            case name
            when 'document-type'; 'tag'
            when 'stylesheets'; @stylesheets
            when 'author'; @config[:author]
            when 'site-copyright-year'; @config[:site_copyright_year]
            when 'site-name'; @config[:site_name]
            when 'lang'; 'ja-JP' # TODO
            when 'copyright-year'; @posts.last.attributes['revision-history'].first.date.year
            when 'description'; "タグ「#{@tag.label}」のついた記事一覧"
            else raise "Unknown attr: #{name}"
            end
          end
          def title; @tag.label; end
          def posts; @posts; end
        end).new(@config, tag, posts, stylesheets)
      )
    end

    def output_tags(tag_docs)
      tag_docs.each do |tag, html|
        destination_file_path = "#{@dest_dir}/tags/#{tag.slug}/index.html"
        destination_dir = File.dirname(destination_file_path)
        unless Dir.exist?(destination_dir)
          FileUtils.makedirs(destination_dir)
        end
        open(destination_file_path, 'w') do |f|
          f.puts(html)
        end
      end
    end

    def generate_post_list(posts)
      html = build_post_list_doc(posts)
      output_post_list(html)
    end

    def build_post_list_doc(posts)
      converter = NulDoc::HTMLConverter.new(nil, { template_dirs: [@template_dir] })
      converter.convert_document(
        (Class.new do
          def initialize(config, posts, stylesheets)
            @config = config
            @posts = posts
            @stylesheets = stylesheets
          end
          def attr(name)
            case name
            when 'document-type'; 'post_list'
            when 'stylesheets'; @stylesheets
            when 'author'; @config[:author]
            when 'site-copyright-year'; @config[:site_copyright_year]
            when 'site-name'; @config[:site_name]
            when 'lang'; 'ja-JP' # TODO
            when 'copyright-year'; @config[:site_copyright_year]
            when 'description'; '記事一覧'
            else raise "Unknown attr: #{name}"
            end
          end
          def title; 'Posts'; end
          def posts; @posts; end
        end).new(@config, posts.reverse, stylesheets)
      )
    end

    def output_post_list(html)
      destination_file_path = "#{@dest_dir}/posts/index.html"
      destination_dir = File.dirname(destination_file_path)
      unless Dir.exist?(destination_dir)
        FileUtils.makedirs(destination_dir)
      end
      open(destination_file_path, 'w') do |f|
        f.puts(html)
      end
    end

    def stylesheets
      stylesheet_file_names = %w[hl.css style.css custom.css]
      stylesheet_file_names.map {|ss_file_name|
        ss_file_path = "#{@static_dir}/#{ss_file_name}"
        hash = Digest::MD5.file(ss_file_path).hexdigest
        "/#{ss_file_name}?#{hash}"
      }
    end
  end
end
