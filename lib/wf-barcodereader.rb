require "wf-barcodereader/version"
require 'RMagick'
require 'fileutils'
require 'zbar'
module Wf
  module Barcodereader

    class Command
      def initialize
        
      end
    end

    class Processor
      @@temp_dir = '/tmp/barcodereader'
      class << self
        include FileUtils

        def sharpen(io)
          extension = File.extname(io)
          sharpened_file_name = File.basename(io).gsub(extension, '') + '_conv' + extension
          begin
            puts "processing #{io} to #{sharpened_file_name}"
            command = "convert -colorspace Gray -level 0%,100%,0.5 -unsharp 5x3+10+0 -flop #{io} #{sharpened_file_name}"
            system command
            return File.join(@@temp_dir, sharpened_file_name)
          rescue Exception => e
            clean
            puts 'Could not process you image'
            puts 'Failed running: ' + command
            puts e.backtrace
          end
        end
        
        def process(io)
          raise "Could not find convert command. Have you installed imagemagick?" unless system('which convert')
          FileUtils.mkdir @@temp_dir unless Dir.exists?(@@temp_dir)
          FileUtils.cd @@temp_dir

          input = Magick::Image.read(sharpen(io)).first
          # convert to PGM
          input.format = 'PGM'

          # load the image from a string
          image = ZBar::Image.from_pgm(input.to_blob)
          processed = image.process
          if processed.empty?
            puts "no barcode found"
            false
          else
            processed.each do |result|
              puts "Code: #{result.data} - Type: #{result.symbology} - Quality: #{result.quality}"
            end
          end
          
          clean
        end
        
        def clean
          rm_f Dir.glob(@@temp_dir + '/*')
        end
      end
    end
  end
end
