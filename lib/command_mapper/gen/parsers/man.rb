require 'command_mapper/gen/parsers/help'

module CommandMapper
  module Gen
    module Parsers
      class Man < Help

        def self.run(command)
          output = `man #{command.command_name}`

          parse(command,output) unless output.empty?
        end

        SECTION_REGEXP = /^[A-Z ]+$/

        def parse_synopsis(line)
          parse_usage(line.strip)
        end

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
                if line =~ /^\s+/
                  parse_synopsis(line.chomp)
                end
              when 'OPTIONS'
                if line =~ OPTION_LINE
                  parse_option(line.chomp)
                end
              end
            end
          end
        end

      end
    end
  end
end
