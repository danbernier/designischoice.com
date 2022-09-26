require 'liquid'
require 'kramdown'
require 'mini_magick'

class PageClass < Liquid::Block
  def initialize(tagname, tag_args_as_string, context)
    @template = Liquid::Template.parse(File.read('templates/page.liquid'))
    super
  end

  def render(context)
    rendered = Kramdown::Document.new(super).to_html
    @template.render(
      context.scopes.reduce(&:merge).merge(
        'content' => rendered,
      )).strip
  end
end
Liquid::Template.register_tag('page', PageClass)

class ProjectClass < Liquid::Block
  def initialize(tagname, tag_args_as_string, context)
    @template = Liquid::Template.parse(File.read('templates/project.liquid'))
    super
  end

  def render(context)
    rendered = Kramdown::Document.new(super).to_html
    @template.render(
      context.scopes.reduce(&:merge).merge(
        'content' => rendered,
      )).strip
  end
end
Liquid::Template.register_tag('project', ProjectClass)

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

  def img(img_path, alt = nil)
    if alt.nil?
      "<img src='/#{img_path}'>"
    else
      "<img src='/#{img_path}' alt='#{alt}'>"
    end
  end
end
Liquid::Template.register_filter(CustomFilters)

def render_all_pages
  Dir.glob('docs/**/*.page').each do |path|
    render_page(path)
  end
end

def render_page(page_path)
  index_path = page_path.sub(/#{File.extname(page_path)}$/, '.html')
  # TOOD: add something here to the liquid context so we know which page it is,
  # so we can do relative-type pathing.
  # p [page_path, index_path]

  File.open(index_path, 'w') do |f|
    f.puts(Liquid::Template.parse(File.read(page_path)).render.strip)
  end
end

if $0 == __FILE__
  `rm -rf docs/images/thumb`
  render_all_pages
end
