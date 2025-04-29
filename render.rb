require 'liquid'
require 'kramdown'
require 'mini_magick'

class PageBlock < Liquid::Block
  def initialize(tagname, tag_args_as_string, context)
    @template = Liquid::Template.parse(File.read('templates/page.liquid'))
    super
  end

  def render(context)
    all_the_assigns_etc =
      context.environments.reduce(&:merge).merge(
        context.scopes.reduce(&:merge))

    render_oembed_for_this_page(all_the_assigns_etc)

    rendered = Kramdown::Document.new(super).to_html
    @template.render!(
      all_the_assigns_etc.merge('content' => rendered)
    ).strip
  end

  private

  def render_oembed_for_this_page(all_the_assigns_etc)
    # https://oembed.com/ for the reference:
    oembed = {
      type: 'link',
      version: '1.0', # required for oembed
      title: [all_the_assigns_etc['title'], 'Design is Choice'].compact.join(' · '),
      author_name: "Daniel Bernier",
      author_url: "https://danbernier.com",
    }

    if File.exist?(File.join("docs", all_the_assigns_etc['url_path'], "hero.png"))
      oembed[:thumbnail_url] = File.join("https://designischoice.com", all_the_assigns_etc['url_path'], "hero.png")
      image = MiniMagick::Image.open(File.join("docs", all_the_assigns_etc['url_path'], "hero.png"))
      oembed[:thumbnail_width] = image.width
      oembed[:thumbnail_height] = image.height
    end

    oembed_dir = File.join("docs", "oembed", all_the_assigns_etc['url_path'])
    `mkdir -p #{oembed_dir}`
    File.open(File.join(oembed_dir, 'oembed.json'), 'w') do |f|
      f.puts oembed.to_json
    end
  end
end
Liquid::Template.register_tag('page', PageBlock)

class ProjectBlock < Liquid::Block
  def initialize(tagname, tag_args_as_string, context)
    @template = Liquid::Template.parse(File.read('templates/project.liquid'))
    super
  end

  def render(context)
    rendered = Kramdown::Document.new(super).to_html
    @template.render!(
      context.environments.reduce(&:merge).merge(
        context.scopes.reduce(&:merge).merge(
          'content' => rendered,
        ))).strip
  end
end
Liquid::Template.register_tag('project', ProjectBlock)

module CustomFilters
  def with_dot_if_present(input)
    return nil if input.nil? || input.empty?
    "#{input} · "
  end

  def thumb(image_path, width = 700)
    begin
      img_tag_path = File.join("images/thumb", image_path)
      img_file_path = "docs/#{img_tag_path}"

      unless File.exist? img_file_path
        `mkdir -p #{File.dirname(img_file_path)}`
        image = MiniMagick::Image.open(File.join("docs", image_path))
        image.resize("#{width}x#{width}")
        image.write(img_file_path)
      end

      img_tag_path
    rescue Exception => x
      pp x
    end
  end

  def img_no_link(img_path, alt = nil)
    if alt.nil?
      "<img src='/#{img_path}'>"
    else
      "<img src='/#{img_path}' alt='#{alt}'>"
    end
  end

  def img(img_path, alt = nil)
    "<a href='/#{img_path}'>#{img_no_link(img_path, alt)}</a>"
  end
end
Liquid::Template.register_filter(CustomFilters)

def render_all_pages
  Dir.glob('docs/**/*.page').each do |path|
    render_page(path)
  end
end

def render_page(page_path)
  html_path = page_path.sub(/#{File.extname(page_path)}$/, '.html')

  #          page_path = docs/path/to/foo.page,
  # and now, html_path = docs/path/to/foo.html

  File.open(html_path, 'w') do |f|
    template = Liquid::Template.parse(File.read(page_path))
    rendered_result = template.render!(
      # 'html_file' => html_path,
      # 'liquid_file' => page_path,
      'url_path' => File.dirname(html_path.gsub('docs/', '')))
    f.puts(rendered_result.strip)
  end
end

if $0 == __FILE__
  `rm -rf docs/images/thumb`
  `rm -rf docs/oembed`
  render_all_pages
end
