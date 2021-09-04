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
#
# Represents the `grep` command
#
class Grep < CommandMapper::Command

  command "grep"

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
  option "--help", value: true
  option "--max-count", equals: true, value: true
  option "--byte-offset"
  option "--line-number"
  option "--line-buffered"
  option "--with-filename"
  option "--no-filename"
  option "--label", equals: true, value: true
  option "--only-matching"
  option "--quiet"
  option "--binary-files", value: true
  option "--text"
  option "-I", name: 	# FIXME: name
  option "--directories", equals: true, value: true
  option "--devices", equals: true, value: true
  option "--recursive"
  option "--dereference-recursive"
  option "--include", equals: true, value: true
  option "--exclude"
  option "--exclude-from", equals: true, value: true
  option "--exclude-dir", equals: true, value: true
  option "--files-without-match"
  option "--files-with-matches"
  option "--count"
  option "--initial-tab"
  option "--null", value: true
  option "--before-context", equals: true, value: true
  option "--after-context", equals: true, value: true
  option "--context", equals: true, value: true
  option "-NUM"
  option "--group-separator", equals: true, value: true
  option "--no-group-separator"
  option "--color"
  option "--colour"
  option "--binary"
  option "-e", name: , value: true	# FIXME: name
  option "-f", name: , value: true	# FIXME: name
  option "-y", name: 	# FIXME: name
  option "-m", name: , value: true	# FIXME: name
  option "--unix-byte-offsets"
  option "-print0"
  option "-A", name: , value: true	# FIXME: name
  option "-B", name: , value: true	# FIXME: name
  option "-C", name: , value: true	# FIXME: name
  option "-D", name: , value: true	# FIXME: name
  option "-d", name: , value: true	# FIXME: name

  argument :grep
  argument :patterns, repeats: true
  argument :file, repeats: true, required: false
  argument :pattern_file, repeats: true

end
```

## Examples

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
