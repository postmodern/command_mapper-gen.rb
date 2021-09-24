# command_mapper-gen

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

```ruby
require 'command_mapper/command'

#
# Represents the `grep` command
#
class Grep < CommandMapper::Command

  command "grep"

  option "--extended-regexp"
  option "--fixed-strings"
  option "--basic-regexp"
  option "--perl-regexp"
  option "--regexp", equals: true, value: :required
  option "--file", equals: true, value: :required
  option "--ignore-case"
  option "--no-ignore-case"
  option "--word-regexp"
  option "--line-regexp"
  option "--null-data"
  option "--no-messages"
  option "--invert-match"
  option "--version"
  option "--help"
  option "--max-count", equals: true, value: :required
  option "--byte-offset"
  option "--line-number"
  option "--line-buffered"
  option "--with-filename"
  option "--no-filename"
  option "--label", equals: true, value: :required
  option "--only-matching"
  option "--quiet"
  option "--binary-files", equals: true, value: :required
  option "--text"
  option "-I", name: 	# FIXME: name
  option "--directories", equals: true, value: :required
  option "--devices", equals: true, value: :required
  option "--recursive"
  option "--dereference-recursive"
  option "--include", equals: true, value: :required
  option "--exclude", equals: true, value: :required
  option "--exclude-from", equals: true, value: :required
  option "--exclude-dir", equals: true, value: :required
  option "--files-without-match", value: :required
  option "--files-with-matches"
  option "--count"
  option "--initial-tab"
  option "--null"
  option "--before-context", equals: true, value: :required
  option "--after-context", equals: true, value: :required
  option "--context", equals: true, value: :required
  option "--group-separator", equals: true, value: :required
  option "--no-group-separator"
  option "--color", equals: :optional, value: :optional
  option "--colour", equals: :optional, value: :optional
  option "--binary"

  argument :patterns, value: :required
  argument :file, value: :optional

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
