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
      #include Imgurup::Color

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

      # Public: prints any given string.
      #
      # s = String output
      #
      # Prints to STDOUT and returns. This method exists to standardize output
      # and for easy mocking or overriding.
      def output(s)
        puts(s)
      end

      # Public: gets $stdin.
      #
      # Returns the $stdin object. This method exists to help with easy mocking
      # or overriding.
      def stdin
        $stdin
      end

      # Public: allows main access to most commands.
      #
      # Returns output based on method calls.
      def delegate(command, major, minor)
        return version           if command == '-v'
        return version           if command == '--version'
        return help              if command == 'help'
        return help              if command[0] == 45 || command[0] == '-' # any - dash options are pleas for help
        return echo(major,minor) if command == 'echo' || command == 'e'
        return upload(major)     if command == 'upload' || command == 'up' || command == 'u'

      end

      # Public: Upload an image to Imgur
      # 
      # Returns nothing
      def upload(major)
        response = ImgurAPI.upload(major)
        puts response if response.start_with?('Error')
        puts "Copied #{Platform.copy(response)} to clipboard" if response.start_with?('http')
      end

      # Public: the version of boom that you're currently running.
      #
      # Returns a String identifying the version number.
      def version
        output "You're running imgurup #{Imgurup::VERSION}."
      end

      # Public: launches preferences JSON file in an editor for you to edit manually.
      #
      # Returns nothing.
      def edit
        Platform.edit(account.json_file)
      end

      # Public: prints all the commands of boom.
      #
      # Returns nothing.
      def help
        text = '
          - imgurup: help ---------------------------------------------------

          imgurup upload <image>                    Upload image and copy link to clipboard


          all other documentation is located at:
          https://github.com/Chris911/imgurup
        '.gsub(/^ {8}/, '') # strip the first eight spaces of every line

        output text
      end

    end
  end
end