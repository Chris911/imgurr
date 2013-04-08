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
        delegate(command, major, minor)
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

      # Public: allows main access to most commands.
      #
      # Returns output based on method calls.
      def delegate(command, major, minor)
        return help unless command
        return no_internet       unless self.internet_connection?

        return version             if command == '--version' || command == '-v' || command == 'version'
        return help                if command == 'help'
        return help                if command[0] == 45 || command[0] == '-' # any - dash options are pleas for help
        return upload(major)       if command == 'upload' || command == 'up' || command == 'u'
        return info(major)         if command == 'info' || command == 'i'
        return delete(major,minor) if command == 'delete' || command == 'd'

      end

      # Public: Upload an image to Imgur
      # 
      # Returns nothing
      def upload(major)
        unless File.exist?(major)
          puts "File #{major} not found."
          return
        end
        response = ImgurAPI.upload(major)
        puts response if response.start_with?('Imgur Error')
        puts "Copied #{Platform.copy(response)} to clipboard" if response.start_with?('http')
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
        unless minor
          puts 'hash found' if storage.hash_exists?(major)
        end
      end

      # Public: the version of boom that you're currently running.
      #
      # Returns a String identifying the version number.
      def version
        puts "You're running imgurr #{Imgurr::VERSION}."
      end

      # Public: launches preferences JSON file in an editor for you to edit manually.
      #
      # Returns nothing.
      def edit
        #Platform.edit(account.json_file)
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
        puts "An Internet connection is required to use this command."
      end

      # Public: prints all the commands of boom.
      #
      # Returns nothing.
      def help
        text = '
          - imgurr: help ---------------------------------------------------

          imgurr help                              This help text
          imgurr version                           Print current version

          imgurr upload <image>                    Upload image and copy link to clipboard
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