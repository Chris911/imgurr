# coding: utf-8

# Command is the main point of entry for boom commands; shell arguments are
# passed through to Command, which then filters and parses through individual
# commands and reroutes them to constituent object classes.
#
# Highly inspired by @holman/boom
#

module Imgurr
  class Command
    class << self

      #include Imgurr::Color

      # Public: executes a command.
      #
      # args    - The actual commands to operate on. Can be as few as zero
      #           arguments or as many as three.
      def execute(*args)
        command = args.shift
        major   = args.shift
        minor   = args.empty? ? nil : args.join(' ')

        return help unless command
        parse_options
        delegate(command, major, minor)
      end

      # Public: Parse extra options
      #
      # returns nothing
      def parse_options
        options[:markdown] = false
        o = OptionParser.new do |opts|
          opts.on('-m', '--markdown', 'Use Markdown Syntax') do
            options[:markdown] = true
          end
          opts.on('-l', '--html', 'Use HTML Syntax') do
            options[:html] = true
          end
          opts.on('-s', '--size PERCENTAGE', 'Image Size') do |value|
            options[:size] = value
          end
          opts.on('-t', '--title TITLE', 'Image Title') do |value|
            options[:title] = value
          end
          opts.on('-d', '--desc DESC', 'Image Title') do |value|
            options[:desc] = value
          end
          opts.on('-v', '--version', 'Print Version') do
            version
            quit
          end
          opts.on('-h', '--help', 'Print Help') do
            help
            quit
          end
        end
        begin
          o.parse!
        rescue OptionParser::MissingArgument => e
          puts "Error: #{e.message}"
          quit
        rescue OptionParser::InvalidOption => e
          puts "Error: #{e.message}"
          quit
        end
      end

      # Public: gets $stdin.
      #
      # Returns the $stdin object. This method exists to help with easy mocking
      # or overriding.
      def stdin
        $stdin
      end

      # Public: accesses the in-memory JSON representation.
      #
      # Returns a Storage instance.
      def storage
        Imgurr.storage
      end

      # Public: accesses the global options
      #
      # Returns Options dictionary
      def options
        Imgurr.options
      end

      # Public: allows main access to most commands.
      #
      # Returns output based on method calls.
      def delegate(command, major, minor)
        return help        unless command
        return no_internet unless self.internet_connection?
        return capture     if command == 'capture' || command == 'cap'

        if major
          return upload(major)       if command == 'upload' || command == 'up' || command == 'u'

          # Get image ID from URL
          if major =~ /.*imgur\.com\/[a-zA-Z0-9]*\.[a-zA-Z]*/
            major = /com\/[a-zA-Z0-9]*/.match(major).to_s.gsub('com/','')
          end

          return unless valid_id major
          return info(major)         if command == 'info' || command == 'i'
          return delete(major,minor) if command == 'delete' || command == 'd'
        else
          return list                if command == 'list' || command == 'l'

          puts "Argument required for commmand #{command}."
          puts "imgurr --help for more information."
          return
        end
      end

      # Public: Upload an image to Imgur
      #
      # Returns nothing
      def upload(major)
        unless File.exist?(major)
          puts "File #{major} not found."
          return
        end
        major = File.absolute_path(major)
        response, success = ImgurAPI.upload(major)
        puts response unless success
        if success
          response = "![#{options[:title].nil? ? 'Screenshot' : options[:title]}](#{response})" if options[:markdown]
          response = build_HTML_response(response) if options[:html]
          copy_succeeded = Platform.copy(response)
          puts copy_succeeded ? "Copied #{response} to clipboard" : "Image url: #{response}"
        end
        storage.save
      end

      # Public: Capture and image and upload to imgur
      #
      # Note: Only supported on OS X for now
      # Returns nothing
      def capture
        unless Platform.darwin?
          puts "Capture command is only supported on OS X for the time being."
          return
        end

        image_path = "#{ENV['HOME']}/.imgurr.temp.png"
        Platform.capture('-W', image_path)

        # User might have canceled or it takes some time to write to disk.
        # Check up to 3 times with 1 sec delay
        3.times do
          if File.exist?(image_path)
            puts "Uploading screenshot..."
            upload(image_path)
            File.delete(image_path)
            break
          end
          sleep(1)
        end
      end

      # Public: List uploaded images
      #
      # Returns nothing
      def list
        items = storage.items
        if items.empty?
          puts 'No items in the list.'
          return
        end

        storage.items.each do |(id, data)|
          puts "#{id}  #{data[:stamp]}  #{data[:source].ljust(48)}"
        end
      end

      # Public: build HTML image tag response
      #
      # Returns a properly formatted HTML <img> tag
      def build_HTML_response(response)
        return "<img src=\"#{response}\" alt=\"#{options[:title].nil? ? 'Screenshot' : options[:title]}\">" if options[:size].nil?

        "<img src=\"#{response}\" alt=\"#{options[:title].nil? ? 'Screenshot' : options[:title]}\" width=\"#{options[:size]}%\">"
      end

      # Public: Get image info
      #
      # Returns nothing
      def info(major)
        response = ImgurAPI.get_info(major)
        puts response
      end

      # Public: Delete image from imgur
      #
      # Returns nothing
      def delete(major,minor)
        major = major.to_sym
        if minor
          delete_hash = minor
        else
          if storage.hash_exists?(major)
            delete_hash = storage.find(major)
          else
            puts 'Delete hash not found in storage.'
            puts 'Use: imgurr delete <id> <delete_hash>'
            return
          end
        end
        if ImgurAPI.delete(delete_hash)
          puts 'Successfully deleted image from Imgur'
          storage.delete(major)
          storage.save
        else
          puts 'Unauthorized Access. Wrong delete hash?'
        end
      end

      # Public: the version of boom that you're currently running.
      #
      # Returns a String identifying the version number.
      def version
        puts "You're running imgurr #{Imgurr::VERSION}."
      end

      # Public: Checks is there's an active internet connection
      #
      # Returns true or false
      def internet_connection?
        begin
          true if open("http://www.google.com/")
        rescue
          false
        end
      end

      # Public: No internet error
      #
      # Returns nothing
      def no_internet
        puts 'An Internet connection is required to use this command.'
      end

      # Public: Quit / Exit program
      #
      # Returns nothing
      def quit
        exit(1)
      end

      # Public: Validate id (major)
      #
      # Returns true if valid id
      def valid_id(major)
        unless major =~ /^[a-zA-Z0-9]*$/
          puts "#{major} is not a valid imgur ID or URL"
          return false
        end
        return true
      end

      # Public: prints all the commands of boom.
      #
      # Returns nothing.
      def help
        text = '
          - imgurr: help ---------------------------------------------------

          imgurr --help                            This help text
          imgurr --version                         Print current version

          imgurr upload <image>                    Upload image and copy link to clipboard
          imgurr upload <image> [-m | --markdown]  Upload image and copy link to clipboard with markdown syntax
                                [-l | --html]      Upload image and copy link to clipboard with HTML syntax
                                [--size=SIZE]      Set image size ratio
                                [--tile="Title"]   Set image title
                                [--desc="Desc" ]   Set image description
          imgurr capture                           Capture a screenshot and upload it (OS X only)
          imgurr list                              List uploaded images
          imgurr info   <id>                       Print image information
          imgurr delete <id>                       Deletes an image from imgur if the deletehash is found locally
          imgurr delete <id> <deletehash>          Deletes an image from imgur with the provided deletehash

          all other documentation is located at:
          https://github.com/Chris911/imgurr
        '.gsub(/^ {8}/, '') # strip the first eight spaces of every line

        puts text
      end

    end
  end
end
