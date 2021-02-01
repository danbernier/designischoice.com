require 'time'

`rm -rf avatars`
`mkdir avatars`

Dir.glob('avatars-raw/*.svg').each do |path|

  filename = File.basename(path)

  clean_filename = if filename =~ /^20\d\d/
                     "#{Time.parse(filename).to_i}.svg"
                     # "#{Time.parse(filename).strftime('%Y-%m-%d.%H.%M.%S')}.svg"
                   else
                     filename
                   end

  src = File.read(path)
  new_src = src.split("\n").map(&:strip).select { |l| l.size > 0 }.join("")

  new_src.gsub!(/title="[^"]+" /, '')

  File.open(File.join('avatars', clean_filename), 'w') do |f|
    f.puts new_src
  end

  p filename => clean_filename, src.size => new_src.size
end
