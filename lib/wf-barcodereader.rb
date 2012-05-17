require "wf-barcodereader/version"
require 'RMagick'
require 'zbar'
module Wf
  module Barcodereader
    class Base
      # include FileUtils
      class << self

        def sharpen(io)
          extension = File.extname(io)
          File.basename(io).gsub(extension, '') + '_conv' + extension
        end
        
        def process(io)
          sharpened_file = sharpen(io)
          cmd = system 'which convert'
          raise "Could not find convert command. Have you installed imagemagick?" unless cmd
          begin
            system  "#{cmd} -unsharp 10x3+10+0 #{io} #{converted_name}"
          rescue Exception => e
            puts 'Could not process you image'
          end

          input = Magick::Image.read(sharpened_file).first
          # convert to PGM
          input.format = 'PGM'

          # load the image from a string
          image = ZBar::Image.from_pgm(input.to_blob)

          image.process.each do |result|
            puts "Code: #{result.data} - Type: #{result.symbology} - Quality: #{result.quality}"
          end
        end
      end
    end
  end
end
