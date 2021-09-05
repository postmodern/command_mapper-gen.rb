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
  option "--max-count", equals: true, value: true
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
  option "--before-context", equals: true, value: true
  option "--after-context", equals: true, value: true
  option "--context", equals: true, value: true
  option "-NUM"
  option "--group-separator", equals: true, value: true
  option "--no-group-separator"
  option "--color"
  option "--colour"
  option "--binary"

  argument :grep
  argument :patterns
  argument :file, repeats: true, required: false

end