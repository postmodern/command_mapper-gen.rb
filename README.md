# command_mapper-gen

[![CI](https://github.com/postmodern/command_mapper-gen.rb/actions/workflows/ruby.yml/badge.svg)](https://github.com/postmodern/command_mapper-gen.rb/actions/workflows/ruby.yml)

* [Source](https://github.com/postmodern/command_mapper-gen)
* [Issues](https://github.com/postmodern/command_mapper-gen/issues)

## Description
  
`command_mapper-gen` parses a command's `--help` output and man-page
and generates the [command_mapper] Ruby class for the command.

## Features

* Parses `--help` output.
* Parses man pages.
* Provides the `command_mapper-gen` command.
* Provides a Rake task.

## Synopsis

```shell
$ command_mapper-gen grep
```

Outputs:

```
Failed to parse line in `grep --help`:

    -NUM                      same as --context=NUM

Failed to match sequence (('	' / SPACES) OPTION ','? ([ \\t]{1, } OPTION_SUMMARY)? !.) at line 1 char 5.

require 'command_mapper/command'

#
# Represents the `grep` command
#
class Grep < CommandMapper::Command

  command "grep" do
    option "--extended-regexp"
    option "--fixed-strings"
    option "--basic-regexp"
    option "--perl-regexp"
    option "--regexp", equals: true, value: true
    option "--file", equals: true, value: true
    option "--ignore-case"
    option "--no-ignore-case"
    option "--word-regexp"
    option "--line-regexp"
    option "--null-data"
    option "--no-messages"
    option "--invert-match"
    option "--version"
    option "--help"
    option "--max-count", equals: true, value: {type: Num.new}
    option "--byte-offset"
    option "--line-number"
    option "--line-buffered"
    option "--with-filename"
    option "--no-filename"
    option "--label", equals: true, value: true
    option "--only-matching"
    option "--quiet"
    option "--binary-files", equals: true, value: true
    option "--text"
    option "-I", name: 	# FIXME: name
    option "--directories", equals: true, value: true
    option "--devices", equals: true, value: true
    option "--recursive"
    option "--dereference-recursive"
    option "--include", equals: true, value: true
    option "--exclude", equals: true, value: true
    option "--exclude-from", equals: true, value: true
    option "--exclude-dir", equals: true, value: true
    option "--files-without-match", value: true
    option "--files-with-matches"
    option "--count"
    option "--initial-tab"
    option "--null"
    option "--before-context", equals: true, value: {type: Num.new}
    option "--after-context", equals: true, value: {type: Num.new}
    option "--context", equals: true, value: {type: Num.new}
    option "--group-separator", equals: true, value: true
    option "--no-group-separator"
    option "--color", equals: :optional, value: {required: false}
    option "--colour", equals: :optional, value: {required: false}
    option "--binary"

    argument :patterns
    argument :file, required: false, repeats: true
  end

end
```

## Examples

## Requirements

* [ruby] >= 2.0.0
* [parslet] ~> 2.0

## Install

```shell
$ gem install command_mapper-gen
```

### Gemfile

```ruby
gem 'command_mapper-gen'
```

## License

Copyright (c) 2021 Hal Brodigan

See {file:LICENSE.txt} for license information.

[command_mapper]: https://github.com/postmodern/command_mapper.rb#readme
[ruby]: htt[s://www.ruby-lang.org/
[parslet]: https://github.com/kschiess/parslet#readme
