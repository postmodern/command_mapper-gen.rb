require 'spec_helper'
require 'command_mapper/gen/parsers/help'

describe CommandMapper::Gen::Parsers::Help do
  let(:command_name) { 'yes' }
  let(:command) { CommandMapper::Gen::Command.new(command_name) }

  subject { described_class.new(command) }

  describe "#initialize" do
    it "must set #command" do
      expect(subject.command).to be(command)
    end
  end

  describe "#parse_usage" do
    let(:usage) { "#{command_name} ARG1 ARG2" }

    before { subject.parse_usage(usage) }

    it "must parse and add the argument to the command" do
      expect(command.arguments.keys).to eq([:arg1, :arg2])
      expect(command.arguments[:arg1].name).to eq(:arg1)
      expect(command.arguments[:arg2].name).to eq(:arg2)
    end

    it "must set the Argument#required to true" do
      expect(command.arguments[:arg2].required).to be(true)
    end

    context "when the argument is optional" do
      let(:usage) { "#{command_name} ARG1 [ARG2]" }

      before { subject.parse_usage(usage) }

      it "must set the Argument#required to false" do
        expect(command.arguments[:arg2].required).to be(false)
      end
    end

    context "when the argument repeats" do
      let(:usage) { "#{command_name} ARG1 ARG2..." }

      before { subject.parse_usage(usage) }

      it "must set the Argument#required to false" do
        expect(command.arguments[:arg2].repeats).to be(true)
      end
    end

    context "when the argument is named OPTS" do
      let(:usage) { "#{command_name} [OPTS] ARG..." }

      before { subject.parse_usage(usage) }

      it "must ignore it" do
        expect(command.arguments.keys).to eq([:arg])
      end
    end

    context "when the argument is named OPTION" do
      let(:usage) { "#{command_name} [OPTION] ARG..." }

      before { subject.parse_usage(usage) }

      it "must ignore it" do
        expect(command.arguments.keys).to eq([:arg])
      end
    end

    context "when the argument is named OPTIONS" do
      let(:usage) { "#{command_name} [OPTIONS] ARG..." }

      before { subject.parse_usage(usage) }

      it "must ignore it" do
        expect(command.arguments.keys).to eq([:arg])
      end
    end

    context "when the usage cannot be parsed" do
      let(:usage) { "FOO BAR BAZ" }

      it "must call #print_parser_error and return nil" do
        expect(subject).to receive(:print_parser_error)

        expect(subject.parse_usage(usage)).to be(nil)
      end
    end
  end

  describe "#parse_option_line" do
    let(:long_flag) { "--option" }
    let(:line)      { "      #{long_flag}     Bla bla bla" }

    before { subject.parse_option_line(line) }

    it "must parse and add the option to the command" do
      expect(command.options.keys).to eq([long_flag])
      expect(command.options[long_flag].flag).to eq(long_flag)
    end

    context "when the option line also includes a short flag" do
      let(:short_flag) { "-o" }
      let(:line)       { "      #{short_flag}, #{long_flag}     Bla bla bla" }

      before { subject.parse_option_line(line) }

      it "must parse and add the option to the command" do
        expect(command.options.keys).to eq([long_flag])
      end
    end

    context "when the option line includes a value" do
      let(:line) { "      #{long_flag} VALUE    Bla bla bla" }

      before { subject.parse_option_line(line) }

      it "must set the Option#value" do
        expect(command.options[long_flag].value).to_not be_nil
      end

      it "must set the OptionValue#required to true" do
        expect(command.options[long_flag].value.required).to be(true)
      end

      context "when the option value is optional" do
        let(:line) { "      #{long_flag} [VALUE]    Bla bla bla" }

        before { subject.parse_option_line(line) }

        it "must set the OptionValue#required to false" do
          expect(command.options[long_flag].value.required).to be(false)
        end
      end

      context "when the option flag and value are joined by a '='" do
        let(:line) { "      #{long_flag}=VALUE    Bla bla bla" }

        before { subject.parse_option_line(line) }

        it "must set Option#equals to true" do
          expect(command.options[long_flag].equals).to be(true)
        end
      end
    end

    context "when the option line cannot be parsed" do
      let(:line) { "   FOO BAR BAZ     Bla bla bla" }

      it "must call #print_parser_error and return nil" do
        expect(subject).to receive(:print_parser_error)

        expect(subject.parse_option_line(line)).to be(nil)
      end
    end
  end

  describe "#parse_subcommand" do
    let(:subcommand) { 'bar' }
    let(:line)       { "   #{subcommand}      bla bla bla" }

    context "when the line starts with a subcommand name" do
      before { subject.parse_subcommand_line(line) }

      it "must parse the subcommand and add it to the command" do
        expect(command.subcommands.keys).to eq([subcommand])
        expect(command.subcommands[subcommand].command_name).to eq(subcommand)
      end
    end

    context "when the line cannot be parsed" do
      let(:line) { "    " }

      it "must return nil" do
        expect(subject.parse_subcommand_line(line)).to be(nil)
      end
    end
  end

  let(:output) do
    <<OUTPUT
Usage: yes [STRING]...
  or:  yes OPTION
Repeatedly output a line with all specified STRING(s), or 'y'.

      --help     display this help and exit
      --version  output version information and exit

GNU coreutils online help: <https://www.gnu.org/software/coreutils/>
Full documentation <https://www.gnu.org/software/coreutils/yes>
or available locally via: info '(coreutils) yes invocation'
OUTPUT
  end

  let(:subcommands_output) do
    <<OUTPUT
NAME:
   runc - Open Container Initiative runtime

runc is a command line client for running applications packaged according to
the Open Container Initiative (OCI) format and is a compliant implementation of the
Open Container Initiative specification.

runc integrates well with existing process supervisors to provide a production
container runtime environment for applications. It can be used with your
existing process monitoring tools and the container will be spawned as a
direct child of the process supervisor.

Containers are configured using bundles. A bundle for a container is a directory
that includes a specification file named "config.json" and a root filesystem.
The root filesystem contains the contents of the container.

To start a new instance of a container:

    # runc run [ -b bundle ] <container-id>

Where "<container-id>" is your name for the instance of the container that you
are starting. The name you provide for the container instance must be unique on
your host. Providing the bundle directory using "-b" is optional. The default
value for "bundle" is the current directory.

USAGE:
   runc [global options] command [command options] [arguments...]

VERSION:
   1.0.2
commit: e15f155-dirty
spec: 1.0.2-dev
go: go1.16.6
libseccomp: 2.5.0

COMMANDS:
   checkpoint  checkpoint a running container
   create      create a container
   delete      delete any resources held by the container often used with detached container
   events      display container events such as OOM notifications, cpu, memory, and IO usage statistics
   exec        execute new process inside the container
   init        initialize the namespaces and launch the process (do not call it outside of runc)
   kill        kill sends the specified signal (default: SIGTERM) to the container's init process
   list        lists containers started by runc with the given root
   pause       pause suspends all processes inside the container
   ps          ps displays the processes running inside a container
   restore     restore a container from a previous checkpoint
   resume      resumes all processes that have been previously paused
   run         create and run a container
   spec        create a new specification file
   start       executes the user defined process in a created container
   state       output the state of a container
   update      update container resource constraints
   help, h     Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --debug             enable debug output for logging
   --log value         set the log file path where internal debug information is written
   --log-format value  set the format used by logs ('text' (default), or 'json') (default: "text")
   --root value        root directory for storage of container state (this should be located in tmpfs) (default: "/run/user/1000/runc")
   --criu value        path to the criu binary used for checkpoint and restore (default: "criu")
   --systemd-cgroup    enable systemd cgroup support, expects cgroupsPath to be of form "slice:prefix:name" for e.g. "system.slice:runc:434234"
   --rootless value    ignore cgroup permission errors ('true', 'false', or 'auto') (default: "auto")
   --help, -h          show help
   --version, -v       print the version
OUTPUT
  end

  describe "#parse" do
    before { subject.parse(output) }

    it "must parse and populate options" do
      expect(command.options.keys).to eq(%w[--help --version])
    end

    it "must parse and populate arguments" do
      expect(command.arguments.keys).to eq([:string])
    end

    context "when the `--help` output includes subcommands" do
      let(:output) { subcommands_output }

      it "must populate the command's subcommands" do
        expect(command.subcommands.keys).to eq(
          %w[
            checkpoint create delete events exec init kill list pause ps restore
            resume run spec start state update help
          ]
        )
      end

      it "must still parse and populate options" do
        expect(command.options.keys).to eq(
          %w[
            --debug --log --log-format --root --criu --systemd-cgroup --rootless
            --help --version
          ]
        )
      end

      it "must still parse and populate arguments"
    end
  end

  describe "#print_parser_error" do
  end

  describe "#parse" do
    before { subject.parse(output) }

    it "must populate the command's options" do
      expect(command.options.keys).to eq(%w[--help --version])
      expect(command.options['--help']).to be_kind_of(CommandMapper::Gen::Option)
      expect(command.options['--version']).to be_kind_of(CommandMapper::Gen::Option)
    end

    it "must populate the command's arguments" do
      expect(command.arguments.keys).to eq([:string])
      expect(command.arguments[:string]).to be_kind_of(CommandMapper::Gen::Argument)
    end

    context "when the output contains subcomands" do
      let(:output) { subcommands_output }

      it "must populate the command's subcommands" do
        expect(command.subcommands.keys).to eq(
          %w[
            checkpoint create delete events exec init kill list pause ps restore
            resume run spec start state update help
          ]
        )
      end
    end
  end

  describe ".parse" do
    subject { described_class }

    before { subject.parse(output,command) }

    it "must parse the output and populate the command" do
      expect(command.options.keys).to eq(%w[--help --version])
      expect(command.options['--help']).to be_kind_of(CommandMapper::Gen::Option)
      expect(command.options['--version']).to be_kind_of(CommandMapper::Gen::Option)

      expect(command.arguments.keys).to eq([:string])
      expect(command.arguments[:string]).to be_kind_of(CommandMapper::Gen::Argument)
    end
  end

  describe ".run" do
    subject { described_class }

    it "must parse the output, populate the commamd, and return the command" do
      parsed_command = subject.run(command)

      expect(parsed_command).to be(command)

      expect(parsed_command.options.keys).to eq(%w[--help --version])
      expect(parsed_command.options['--help']).to be_kind_of(CommandMapper::Gen::Option)
      expect(parsed_command.options['--version']).to be_kind_of(CommandMapper::Gen::Option)

      expect(parsed_command.arguments.keys).to eq([:string])
      expect(parsed_command.arguments[:string]).to be_kind_of(CommandMapper::Gen::Argument)
    end

    context "when the command is not installed" do
      let(:command_name) { "foo" }

      before do
        allow(subject).to receive(:`).and_raise(Errno::ENOENT.new("foo"))
      end

      it "must return nil" do
        expect(subject.run(command)).to be(nil)
      end
    end

    context "when there is no output from `--help`" do
      let(:command_name) { "foo" }

      before do
        allow(subject).to receive(:`).with("#{command_name} --help 2>&1").and_return("")
      end

      it "must try executing -h" do
        expect(subject).to receive(:`).with("#{command_name} -h 2>&1").and_return("")

        subject.run(command)
      end

      context "but `-h` also produces no output" do
        before do
          allow(subject).to receive(:`).with("#{command_name} --help 2>&1").and_return("")
          allow(subject).to receive(:`).with("#{command_name} -h 2>&1").and_return("")
        end

        it "must return nil" do
          expect(subject.run(command)).to be(nil)
        end
      end
    end
  end
end
