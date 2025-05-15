require 'minitest/autorun'

Dir.glob('test/**/*.rb').each { |p| load(p) }
