# frozen_string_literal: true

require_relative "isort/version"

require 'optparse'

module Isort
  class Error < StandardError; end

  class FileSorter
    def initialize(file_path)
      @file_path = file_path
    end

    def sort_imports
      # Read the file content
      lines = File.readlines(@file_path, chomp: true).map { |line| line.gsub("\r", "") }

      # Separate import-related lines and other content
      imports = lines.select { |line| line =~ /^\s*(require|require_relative|include)\s/ }
      non_imports = lines.reject { |line| line =~ /^\s*(require|require_relative|include)\s/ }

      # Sort the import lines alphabetically
      sorted_imports = imports.sort

      # Combine sorted imports with other lines
      sorted_content = (sorted_imports + non_imports).join

      # Write the sorted content back to the file
      File.write(@file_path, sorted_content)
    end

    def sort_and_format_imports
      # Read the file content
      lines = File.readlines(@file_path)

      # Separate and group lines
      requires = extract_lines(lines, /^require\s/)
      require_relatives = extract_lines(lines, /^require_relative\s/)
      includes = extract_lines(lines, /^include\s/)
      extends = extract_lines(lines, /^extend\s/)
      autoloads = extract_lines(lines, /^autoload\s/)
      usings = extract_lines(lines, /^using\s/)
      others = lines.reject { |line| [requires, require_relatives, includes, extends, autoloads, usings].flatten.include?(line) }

      # Format and sort each group
      formatted_imports = []
      formatted_imports << format_group("require", requires)
      formatted_imports << format_group("require_relative", require_relatives)
      formatted_imports << format_group("include", includes)
      formatted_imports << format_group("extend", extends)
      formatted_imports << format_group("autoload", autoloads)
      formatted_imports << format_group("using", usings)

      # Combine formatted imports with the rest of the file
      sorted_content = (formatted_imports + others).join

      # Write the sorted content back to the file
      File.write(@file_path, sorted_content)
    end

    private

    def extract_lines(lines, regex)
      lines.select { |line| line =~ regex }
    end

    def format_group(type, lines)
      return [] if lines.empty?

      # Remove duplicates and sort
      lines.uniq.sort
    end

  end

  class CLI
    def self.start
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: sort [options]"

        opts.on("-fFILE", "--file=FILE", "File to sort") do |file|
          options[:file] = file
        end
        opts.on("-dDIRECTORY", "--directory=DIRECTORY", "Specify a directory to sort") do |dir|
          options[:directory] = dir
        end
      end.parse!

      if options[:file]
        sorter = FileSorter.new(options[:file])
        sorter.sort_and_format_imports
        puts "Imports sorted in #{options[:file]}"
      elsif options[:directory]
        count = 0
        Dir.glob("#{options[:directory]}/**/*.rb").each do |file|
          count += 1
          sorter = FileSorter.new(file)
          sorter.sort_and_format_imports
        end
        puts "Sorted imports in #{count} files in directory: #{options[:directory]}"
      else
        puts "Please specify a file using -f or --file"
      end
    end
  end
end
