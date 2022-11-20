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
          'source-highlighter' => 'rouge',
          'reproducible' => true,
          'sectids' => false,
        },
        @content_dir,
        @template_dir,
      )
    end

    def run
      posts = generate_posts(@content_dir + '/posts')
      generate_tags(posts)
      generate_posts_list(posts)
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
      erb = ERB.new(File.read(@template_dir + '/tag.html.erb'), trim_mode: '<>')
      erb.result_with_hash({
        stylesheets: stylesheets,
        tag: tag,
        posts: posts,
        author: @config[:author],
        site_copyright_year: @config[:site_copyright_year],
        site_name: @config[:site_name],
        lang: 'ja-JP', # TODO
        copyright_year: posts.last.attributes['revision-history'].first.date.year,
        description: "タグ「#{tag.label}」のついた記事一覧",
      })
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

    def generate_posts_list(posts)
      html = build_posts_list_doc(posts)
      output_posts_list(html)
    end

    def build_posts_list_doc(posts)
      erb = ERB.new(File.read(@template_dir + '/posts_list.html.erb'), trim_mode: '<>')
      erb.result_with_hash({
        stylesheets: stylesheets,
        posts: posts.reverse,
        author: @config[:author],
        site_copyright_year: @config[:site_copyright_year],
        site_name: @config[:site_name],
        lang: 'ja-JP', # TODO
        copyright_year: @config[:site_copyright_year],
        description: "記事一覧",
        doctitle: "Posts",
        header_title: "Posts",
      })
    end

    def output_posts_list(html)
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
