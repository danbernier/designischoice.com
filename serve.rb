require 'sinatra'

# set :public_folder, __dir__ + '/docs'

require_relative 'render'
before do
  # load 'render.rb'
  # render_all_pages
end

get '/*' do
  path = File.join('docs', params[:splat])
  if Dir.exist?(path)

    # # This simulates production too:
    # # % curl -Is "https://designischoice.com/projects/pool-noodle-animals"
    # # HTTP/2 301
    # # location: https://designischoice.com/projects/pool-noodle-animals/
    # #
    # # It's so <img src='foo.png'> will be relative to
    # # /projects/pool-noodle-animals/, not relative to /projects/.
    # redirect to("#{File.join(params[:splat])}/") unless path.end_with?('/')
    #
    # # ...actually, we don't need to do this if we have `thumb` and `img`
    # rewrite all the image paths, which is what we do now.

    if File.exist?(File.join(path, 'index.html'))
      last_modified(File.mtime(path))
      render_page(File.join(path, 'index.page'))
      send_file(File.join(path, 'index.html'))
    end
  elsif File.exist?(path)
    last_modified(File.mtime(path))
    send_file(path)
  end
end
