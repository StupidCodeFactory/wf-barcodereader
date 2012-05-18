require "wf-barcodereader/version"
require 'RMagick'
require 'fileutils'
require 'zbar'
require 'rally_rest_api'
require 'date'
require 'active_support/core_ext'
module Wf
  module Barcodereader
    TMP_DIR = '/tmp/barcodereader'
    class Command
      include FileUtils
      def initialize
        FileUtils.mkdir TMP_DIR unless Dir.exists?(TMP_DIR)
        cd TMP_DIR
        found = false
        max_try = 20
        while !found && max_try > 0
          sleep 0.5
          system("imagesnap -q")
          found = Processor.process File.expand_path('snapshot.jpg')
          max_try -= 1
        end
        if !found
          puts "Could not find any barecodes"
        else
          found.each do |result|
            puts "Code: #{result.data} - Type: #{result.symbology} - Quality: #{result.quality}"

            puts "Updating task on Rally..."


            username = ENV["RALLY_EMAIL"]
            password = ENV["RALLY_PASSWORD"]

            rally = RallyRestAPI.new(username: username, password: password, version: "1.33")

            project = rally.find(:project) { equal :name, 'Fork Handles' }.results.first
            @iteration = rally.find(:iteration) { 
              equal :project, project
              less_than_equal :start_date, Date.today.to_formatted_s
              greater_than_equal :end_date, Date.today.to_formatted_s 
            }.results.last

            pro_q = project.to_q
            itr_q = @iteration.to_q


            task = rally.find(:task) do
              equal(:project, pro_q)
              equal(:iteration, itr_q)
              equal(:object_i_d, result.data)
            end.results.first


            task.update(state: "Completed")


            puts "Task updated!"

          end
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
