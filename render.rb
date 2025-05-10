require 'liquid'
require 'kramdown'
require 'mini_magick'

class PageBlock < Liquid::Block
  def initialize(tagname, tag_args_as_string, context)
    @template = Liquid::Template.parse(File.read('templates/page.liquid'))
    super
  end

  class ImgFile < Liquid::Drop
    def initialize(url_path, filename)
      @filename = File.join(url_path, filename)
      @docs_path = File.join("docs", @filename)

      raise "Missing image file: #{@filename}" unless file_is_present?

      @image = MiniMagick::Image.open(@docs_path)
    end

    def file_is_present?
      File.exist?(@docs_path)
    end

    def url
      File.join("https://designischoice.com", @filename)
    end

    def width
      @image.width
    end

    def height
      @image.height
    end

    def img_type
      case File.extname(@filename)
      when '.jpg', '.jpeg'
        'image/jpeg'
      when '.png'
        'image/png'
      when '.gif'
        'image/gif'
      else
        raise "Unknown hero image file type: #{@filename}"
      end
    end
  end

  def render(context)
    all_the_assigns_etc =
      context.environments.reduce(&:merge).merge(
        context.scopes.reduce(&:merge))

    hero_file = if (hero = all_the_assigns_etc['hero'])
                  ImgFile.new(all_the_assigns_etc['url_path'], hero)
                end

    render_oembed_for_this_page(all_the_assigns_etc, hero_file)

    rendered = Kramdown::Document.new(super).to_html
    @template.render!(
      all_the_assigns_etc.merge(
        'content' => rendered,
        'hero_file' => hero_file
      )
    ).strip
  end

  private

  def render_oembed_for_this_page(all_the_assigns_etc, hero_file)
    # https://oembed.com/ for the reference:
    oembed = {
      type: 'link',
      version: '1.0', # required for oembed
      title: [all_the_assigns_etc['title'], 'Design is Choice'].compact.join(' · '),
      provider_name: 'Design is Choice',
      provider_url: 'https://designischoice.com',
      author_name: "Daniel Bernier",
      author_url: "https://danbernier.com",
    }

    if hero_file
      oembed[:thumbnail_url] = hero_file.url
      oembed[:thumbnail_width] = hero_file.width
      oembed[:thumbnail_height] = hero_file.height
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

  # thumb: resizes, returns a new path
  # img: wraps given path in <a href=''><img src=''></a>
  # img_no_path: wraps given path in just <img src=''>
  #
  # ...rename `img` to `linked_img`, and `img_no_link` to `img`?

  def thumb(image_path, width = 700)
    url_path = context.environments.reverse.map { |env| env['url_path'] }.compact.reject(&:empty?).first
    unless url_path == '.'
      unless image_path.start_with?(url_path)
        image_path = File.join(url_path, image_path)
      end
    end

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

    root = 'https://designischoice.com'

    url_path = File.dirname(html_path.gsub('docs/', ''))
    url_with_host = url_path == '.' ? root : "#{root}/#{url_path}"
    rendered_result = template.render!(
      # 'html_file' => html_path,
      # 'liquid_file' => page_path,
      'url_path' => url_path,
      'url_with_host' => url_with_host,
    )
    f.puts(rendered_result.strip)
  end
end

if $0 == __FILE__
  `rm -rf docs/images/thumb`
  `rm -rf docs/oembed`
  render_all_pages
end
