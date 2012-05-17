require "wf-barcodereader/version"
require 'RMagick'
require 'fileutils'
require 'zbar'
module Wf
  module Barcodereader
    TMP_DIR = '/tmp/barcodereader'
    class Command
      include FileUtils
      def initialize
        FileUtils.mkdir TMP_DIR unless Dir.exists?(TMP_DIR)
        cd TMP_DIR
        found = false
        max_try = 3
        while !found && max_try > 0
          sleep 3
          system("imagesnap -q")
          found = Processor.process File.expand_path('snapshot.jpg')
          max_try -= 1
        end
        unless found
          puts "Could not find any barecodes"
        end
      end
    end

    class Processor

      class << self
        include FileUtils

        def sharpen(io)
          
          extension = File.extname(io)
          sharpened_file_name = File.join(TMP_DIR, File.basename(io).gsub(extension, '') + '_conv' + extension)
          begin
            command = "convert -auto-level -colorspace Gray -level 40%,60%,1 -unsharp 5x4+4+0 #{io} #{sharpened_file_name}"
            system command
            return sharpened_file_name
          rescue Exception => e
            clean
            puts 'Could not process you image'
            puts 'Failed running: ' + command
            puts e.backtrace
          end
        end
        
        def process(io)
          raise "Could not find convert command. Have you installed imagemagick?" unless system('which convert',  :out => '/dev/null')
          input = Magick::Image.read(sharpen(io)).first
          # convert to PGM
          input.format = 'PGM'

          # load the image from a string
          image = ZBar::Image.from_pgm(input.to_blob)
          processed = image.process
          if processed.empty?
            clean
            return false
          else
            # processed.each do |result|
            #   puts "Code: #{result.data} - Type: #{result.symbology} - Quality: #{result.quality}"
            # end
            clean
            return processed
          end
        end
        
        def clean
          rm_f Dir.glob(TMP_DIR + '/*')
        end
      end
    end
  end
end
