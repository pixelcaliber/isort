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
      lines = File.readlines(@file_path)

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
  end
  class CLI
    def self.start
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: sort [options]"

        opts.on("-fFILE", "--file=FILE", "File to sort") do |file|
          options[:file] = file
        end
      end.parse!

      if options[:file]
        sorter = FileSorter.new(options[:file])
        sorter.sort_imports
        puts "Imports sorted in #{options[:file]}"
      else
        puts "Please specify a file using -f or --file"
      end
    end
  end
end
