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

        # Get image ID from URL
        if major
          return upload(major)       if command == 'upload' || command == 'up' || command == 'u'

          if major =~ /.*imgur\.com\/[a-zA-Z0-9]*\.[a-zA-Z]*/
            major = /com\/[a-zA-Z0-9]*/.match(major).to_s.gsub('com/','')
          end

          return unless valid_id major
          return info(major)         if command == 'info' || command == 'i'
          return delete(major,minor) if command == 'delete' || command == 'd'
        else
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
        response, success = ImgurAPI.upload(major)
        puts response unless success
        if success
          response = "![#{options[:title].nil? ? 'Screenshot' : options[:title]}](#{response})" if options[:markdown]
          puts "Copied #{Platform.copy(response)} to clipboard"
        end
        storage.save
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
          imgurr upload <image> [-m|--markdown ]   Upload image and copy link to clipboard with markdown syntax
                                [--tile="Title"]   Set image title
                                [--desc="Desc" ]   Set image description
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