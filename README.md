# Isort

A Ruby gem that automatically sorts and organizes your import statements in Ruby files.

## Installation

```bash
gem install isort
```

## Usage

### Command Line

```bash
isort -f path/to/your/file.rb
```

### In Ruby Code

```ruby
require 'isort'

sorter = Isort::FileSorter.new('path/to/your/file.rb')
sorter.sort_and_format_imports
```

## Features

- Sorts require statements alphabetically
- Groups imports by type (require, require_relative, include, extend)
- Preserves code structure and spacing
- Maintains conditional requires
- Respects nested class and module definitions

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/abhinvv1/isort.

## License

The gem is available as open source under the terms of the MIT License.
