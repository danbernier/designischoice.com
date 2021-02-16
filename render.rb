require 'liquid'
require 'kramdown'

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
end
Liquid::Template.register_filter(CustomFilters)

def render_all_pages
  Dir.glob('docs/**/*.page').each do |path|
    render_page(path)
  end
end

def render_page(page_path)
  index_path = page_path.sub(/#{File.extname(page_path)}$/, '.html')

  File.open(index_path, 'w') do |f|
    f.puts(Liquid::Template.parse(File.read(page_path)).render.strip)
  end
end

if $0 == __FILE__
  render_all_pages
end
