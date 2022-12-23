import { dirname, join, joinGlobs } from "std/path/mod.ts";
import { ensureDir } from "std/fs/mod.ts";
import { expandGlob } from "std/fs/expand_glob.ts";
import { Config } from "./config.ts";
import { parseDocBookFile } from "./docbook/parse.ts";
import { writeHtmlFile } from "./html.ts";
import { Document } from "./docbook/document.ts";

export async function run(config: Config) {
  const _posts = await generatePosts(config);
  // generateTags(posts, config);
  // generatePostList(posts, config);
}

async function generatePosts(config: Config) {
  const sourceDir = join(Deno.cwd(), config.locations.contentDir, "/posts");
  const postFiles = await collectPostFiles(sourceDir);
  // TODO
  // const posts = await parsePosts(postFiles, config);
  const posts = await parsePosts([postFiles[0]], config);
  outputPosts(posts, config);
  return posts;
}

async function collectPostFiles(sourceDir: string): Promise<string[]> {
  const filePaths = [];
  const globPattern = joinGlobs([sourceDir, "**", "*.xml"]);
  for await (const entry of expandGlob(globPattern)) {
    filePaths.push(entry.path);
  }
  return filePaths;
}

async function parsePosts(
  postFiles: string[],
  _config: Config,
): Promise<Document[]> {
  const posts = [];
  for (const postFile of postFiles) {
    posts.push(await parseDocBookFile(postFile));
  }
  return posts;
}

function outputPosts(posts: Document[], config: Config) {
  const cwd = Deno.cwd();
  const contentDir = join(cwd, config.locations.contentDir);
  const destDir = join(cwd, config.locations.destDir);
  for (const post of posts) {
    const destinationFilePath = join(
      post.sourceFilePath.replace(contentDir, destDir).replace(".xml", ""),
      "index.html",
    );
    ensureDir(dirname(destinationFilePath));
    writeHtmlFile(post, destinationFilePath);
  }
}

/*
function generateTags(posts) {
  const tagsAndPosts = collectTags(posts);
  const tag_docs = buildTagDocs(tagsAndPosts);
  outputTags(tag_docs);
}
*/

/*
function collectTags(posts) {
  const tagsAndPosts = [];
  for (const post of posts) {
    for (const tag of post.tags) {
      tagsAndPosts[tag] ||= [];
      tagsAndPosts[tag].push(post);
    }
  }
  return tagsAndPosts
    .transformValues((posts) =>
      posts.sortBy((post) => post.revisions.first.date).reverse()
    )
    .sortBy((tag, _) => tag)
    .to_h();
}
*/

/*
function buildTagDocs(tagsAndPosts) {
  tagsAndPosts.map((tag, posts) => [tag, buildTagDoc(tag, posts)]);
}
*/

/*
function buildTagDoc() {
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
}
  */

/*
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
    */
