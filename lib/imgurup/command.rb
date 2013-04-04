# coding: utf-8

# Command is the main point of entry for boom commands; shell arguments are
# passed through to Command, which then filters and parses through individual
# commands and reroutes them to constituent object classes.
#
# Highly inspired by @holman/boom
#

module Imgur
  class Command
    class << self
      
      # Public: executes a command.
      #
      # args    - The actual commands to operate on. Can be as few as zero
      #           arguments or as many as three.
      def execute(*args)
        command = args.shift
        major   = args.shift
        minor   = args.empty? ? nil : args.join(' ')

        return overview unless command
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
        return all               if command == 'all'
        return edit              if command == 'edit'
        return version           if command == "-v"
        return version           if command == "--version"
        return help              if command == 'help'
        return help              if command[0] == 45 || command[0] == '-' # any - dash options are pleas for help
        return echo(major,minor) if command == 'echo' || command == 'e'
        return copy(major,minor) if command == 'copy' || command == 'c'
        return open(major,minor) if command == 'open' || command == 'o'
        return random(major)     if command == 'random' || command == 'rand' || command == 'r'

        # if we're operating on a List
        if storage.list_exists?(command)
          return delete_list(command) if major == '--delete'
          return detail_list(command) unless major
          unless minor == '--delete'
            return add_item(command,major,minor) if minor
            return add_item(command,major,stdin.read) if stdin.stat.size > 0
            return search_list_for_item(command, major)
          end
        end

        if minor == '--delete' and storage.item_exists?(major)
          return delete_item(command, major)
        end

        return search_items(command) if storage.item_exists?(command) and !major

        return create_list(command, major, stdin.read) if !minor && stdin.stat.size > 0
        return create_list(command, major, minor)
      end

      # Public: the version of boom that you're currently running.
      #
      # Returns a String identifying the version number.
      def version
        output "You're running imgurup #{Imgurup::VERSION}."
      end

      # Public: launches prefenences JSON file in an editor for you to edit manually.
      #
      # Returns nothing.
      def edit
        Platform.edit(account.json_file)
      end

      # Public: prints all the commands of boom.
      #
      # Returns nothing.
      def help
        text = %{
          - imgurup: help ---------------------------------------------------

          all other documentation is located at:
            https://github.com/Chris911/imgurup
        }.gsub(/^ {8}/, '') # strip the first eight spaces of every line

        output text
      end

    end
  end
end