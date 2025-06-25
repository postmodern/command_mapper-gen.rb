### 0.1.1 / 2025-06-24

* Improvements and bug fixes for `--help` parsing logic:
  * Ignore explicit option flags when parsing the `usage:` line.
  * Tweak the option parser for Go-style `--help` output.

### 0.1.0 / 2021-11-25

* Initial release:
  * Added {CommandMapper::Gen::Types::Str}.
  * Added {CommandMapper::Gen::Types::Num}.
  * Added {CommandMapper::Gen::Types::Map}.
  * Added {CommandMapper::Gen::Types::Enum}.
  * Added {CommandMapper::Gen::Types::KeyValue}.
  * Added {CommandMapper::Gen::Types::List}.
  * Added {CommandMapper::Gen::Arg}.
  * Added {CommandMapper::Gen::Argument}.
  * Added {CommandMapper::Gen::OptionValue}.
  * Added {CommandMapper::Gen::Option}.
  * Added {CommandMapper::Gen::Command}.
  * Added {CommandMapper::Gen::Parsers::Common}.
  * Added {CommandMapper::Gen::Parsers::Usage}.
  * Added {CommandMapper::Gen::Parsers::Options}.
  * Added {CommandMapper::Gen::Parsers::Help}.
  * Added {CommandMapper::Gen::Parsers::Man}.
  * Added {CommandMapper::Gen::CLI}.
