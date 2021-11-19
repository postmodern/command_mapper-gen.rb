require 'spec_helper'
require 'command_mapper/gen/parsers/man'

describe CommandMapper::Gen::Parsers::Man do
  let(:command_name) { 'yes' }
  let(:command)      { CommandMapper::Gen::Command.new(command_name) }

  subject { described_class.new(command) }

  let(:output) do
    <<MAN_PAGE
YES(1)                                User Commands                               YES(1)

NAME
       yes - output a string repeatedly until killed

SYNOPSIS
       yes [STRING]...
       yes OPTION

DESCRIPTION
       Repeatedly output a line with all specified STRING(s), or 'y'.

       --help display this help and exit

       --version
              output version information and exit

AUTHOR
       Written by David MacKenzie.

REPORTING BUGS
       GNU coreutils online help: <https://www.gnu.org/software/coreutils/>
       Report any translation bugs to <https://translationproject.org/team/>

COPYRIGHT
       Copyright  © 2020 Free Software Foundation, Inc.  License GPLv3+: GNU GPL version
       3 or later <https://gnu.org/licenses/gpl.html>.
       This is free software: you are free to change and redistribute it.  There  is  NO
       WARRANTY, to the extent permitted by law.

SEE ALSO
       Full documentation <https://www.gnu.org/software/coreutils/yes>
       or available locally via: info '(coreutils) yes invocation'

GNU coreutils 8.32                      July 2021                                 YES(1)
MAN_PAGE
  end

  describe ".run" do
    subject { described_class }

    context "when the command has a man page" do
      before do
        allow(subject).to receive(:`).with("man #{command_name} 2>/dev/null").and_return(output)
      end

      it "must parse the command's man page, populate the command, and return the command" do
        parsed_command = subject.run(command)

        expect(parsed_command).to be(command)

        expect(parsed_command.arguments.keys).to eq([:string])
        expect(parsed_command.arguments[:string]).to be_kind_of(CommandMapper::Gen::Argument)

        expect(parsed_command.options.keys).to eq(%w[--help --version])
        expect(parsed_command.options['--help']).to be_kind_of(CommandMapper::Gen::Option)
        expect(parsed_command.options['--version']).to be_kind_of(CommandMapper::Gen::Option)
      end
    end

    context "when the command has no man page" do
      let(:command_name) { 'foo' }

      it "must return nil" do
        expect(subject.run(command)).to be(nil)
      end
    end

    context "but the `man` command is not installed" do
      before do
        allow(subject).to receive(:`).with("man #{command_name} 2>/dev/null").and_raise(Errno::ENOENT.new("man"))
      end

      it "must return nil" do
        expect(subject.run(command)).to be(nil)
      end
    end
  end

  describe "#parse" do
    before { subject.parse(output) }

    context "when the arguments are defined in the DESCRIPTION section" do
      it "must populate the command's options" do
        expect(command.options.keys).to eq(%w[--help --version])
        expect(command.options['--help']).to be_kind_of(CommandMapper::Gen::Option)
        expect(command.options['--version']).to be_kind_of(CommandMapper::Gen::Option)
      end
    end

    context "when the arguments are defined in the OPTIONS section" do
      let(:output) do
    <<MAN_PAGE
YES(1)                                User Commands                               YES(1)

NAME
       yes - output a string repeatedly until killed

SYNOPSIS
       yes [STRING]...
       yes OPTION

DESCRIPTION
       Repeatedly output a line with all specified STRING(s), or 'y'.

OPTIONS
       --help display this help and exit

       --version
              output version information and exit

AUTHOR
       Written by David MacKenzie.

REPORTING BUGS
       GNU coreutils online help: <https://www.gnu.org/software/coreutils/>
       Report any translation bugs to <https://translationproject.org/team/>

COPYRIGHT
       Copyright  © 2020 Free Software Foundation, Inc.  License GPLv3+: GNU GPL version
       3 or later <https://gnu.org/licenses/gpl.html>.
       This is free software: you are free to change and redistribute it.  There  is  NO
       WARRANTY, to the extent permitted by law.

SEE ALSO
       Full documentation <https://www.gnu.org/software/coreutils/yes>
       or available locally via: info '(coreutils) yes invocation'

GNU coreutils 8.32                      July 2021                                 YES(1)
MAN_PAGE
      end

      it "must populate the command's options" do
        expect(command.options.keys).to eq(%w[--help --version])
        expect(command.options['--help']).to be_kind_of(CommandMapper::Gen::Option)
        expect(command.options['--version']).to be_kind_of(CommandMapper::Gen::Option)
      end
    end

    it "must populate the command's arguments" do
      expect(command.arguments.keys).to eq([:string])
      expect(command.arguments[:string]).to be_kind_of(CommandMapper::Gen::Argument)
    end
  end
end
