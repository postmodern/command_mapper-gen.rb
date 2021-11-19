require 'command_mapper/gen/parsers/help'

module CommandMapper
  module Gen
    module Parsers
      class Man < Help

        #
        # Parses the command's man page.
        #
        # @param [Command] command
        #   The command object to parse data into.
        #
        # @return [Command, nil]
        #   Returns `nil` if the command could not be found.
        #
        def self.run(command)
          output = begin
                     `man #{command.man_page} 2>/dev/null`
                   rescue Errno::ENOENT
                   end

          parse(output,command) unless (output.nil? || output.empty?)
        end

        #
        # Parses a command synopsis line.
        #
        # @param [String] line
        #   The command string.
        #
        def parse_synopsis(line)
          parse_usage(line.strip)
        end

        SECTION_REGEXP = /^[A-Z ]+$/

        INDENT = '       '

        OPTION_LINE = /^#{INDENT}-(?:[A-Za-z0-9]|-[A-Za-z0-9])/

        #
        # Parses the man page output into {#command}.
        #
        # @param [String] output
        #   The plain-text man page output to parse.
        #
        def parse(output)
          section = nil

          output.each_line do |line|
            line.chomp!

            if line =~ SECTION_REGEXP
              section = line
            else
              case section
              when 'SYNOPSIS'
                # SYNPSIS lines are indented
                if line.start_with?(INDENT)
                  parse_synopsis(line.chomp)
                end
              when 'DESCRIPTION', 'OPTIONS'
                if line =~ OPTION_LINE
                  parse_option_line(line.chomp)
                end
              end
            end
          end
        end

      end
    end
  end
end
