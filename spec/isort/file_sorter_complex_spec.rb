require 'isort'
require 'spec_helper'
require 'tempfile'


RSpec.describe Isort::FileSorter do
  let(:tempfile) { Tempfile.new(['test', '.rb']) }
  let(:sorter) { described_class.new(tempfile.path) }

  after do
    tempfile.close
    tempfile.unlink
  end

  describe '#sort_and_format_imports' do
    context 'with basic import sorting' do
      it 'sorts different types of imports correctly' do
        content = <<~RUBY
          extend ActiveSupport::Concern
          require_relative 'helper'
          require 'json'
          include Enumerable
          require 'yaml'
          require_relative 'version'
          autoload :Constants, 'constants'
          using Module
        RUBY

        tempfile.write(content)
        tempfile.flush

        sorter.sort_and_format_imports

        expected = <<~RUBY
          require 'json'
          require 'yaml'
          
          require_relative 'helper'
          require_relative 'version'
          
          include Enumerable
          
          extend ActiveSupport::Concern
          
          autoload :Constants, 'constants'
          
          using Module
        RUBY

        expect(File.read(tempfile.path)).to eq(expected)
      end
    end

    context 'with edge cases' do
      it 'handles empty files' do
        tempfile.write('')
        tempfile.flush

        expect { sorter.sort_and_format_imports }.not_to raise_error
        expect(File.read(tempfile.path)).to eq('')
      end

      it 'handles files with only whitespace' do
        content = "\n\n  \n\t\n"
        tempfile.write(content)
        tempfile.flush

        sorter.sort_and_format_imports
        expect(File.read(tempfile.path)).to eq("\n\n  \n\t\n")
      end

      it 'handles files with no imports' do
        content = <<~RUBY
          class MyClass
            def my_method
              puts "Hello"
            end
          end
        RUBY

        tempfile.write(content)
        tempfile.flush

        sorter.sort_and_format_imports
        expect(File.read(tempfile.path)).to eq(content)
      end

      it 'handles commented imports' do
        content = <<~RUBY
          require 'json'
          # require 'yaml'
          require_relative 'helper'
          # require_relative 'version'
        RUBY

        tempfile.write(content)
        tempfile.flush

        expected = <<~RUBY
          require 'json'
          
          # require 'yaml'
          require_relative 'helper'
          
          # require_relative 'version'
        RUBY

        sorter.sort_and_format_imports
        expect(File.read(tempfile.path)).to eq(expected)
      end

      it 'handles imports with inline comments' do
        content = <<~RUBY
          require 'json' # Used for JSON parsing
          require 'yaml' # YAML parser
          require_relative 'helper' # Helper methods
        RUBY

        tempfile.write(content)
        tempfile.flush

        sorter.sort_and_format_imports
        expect(File.read(tempfile.path)).to include("require 'json'")
        expect(File.read(tempfile.path)).to include("require 'yaml'")
        expect(File.read(tempfile.path)).to include("require_relative 'helper'")
      end
    end

    # context 'with complex scenarios' do
    #   it 'handles duplicate imports' do
    #     content = <<~RUBY
    #       require 'json'
    #       require 'yaml'
    #       require 'json'
    #       require_relative 'helper'
    #       require_relative 'helper'
    #     RUBY
    #
    #     tempfile.write(content)
    #     tempfile.flush
    #
    #     expected = <<~RUBY
    #       require 'json'
    #       require 'yaml'
    #
    #       require_relative 'helper'
    #     RUBY
    #
    #     sorter.sort_and_format_imports
    #     expect(File.read(tempfile.path)).to eq(expected)
    #   end
    # end

    context 'with error handling' do
      it 'raises error for non-existent file' do
        sorter = described_class.new('nonexistent.rb')
        expect { sorter.sort_and_format_imports }.to raise_error(Errno::ENOENT)
      end

      it 'handles files with invalid encoding' do
        # Create a file with invalid UTF-8
        File.write(tempfile.path, "require 'json'\xFF\xFF\xFF")
        expect { sorter.sort_and_format_imports }.to raise_error(Encoding::CompatibilityError)
      end
    end

    context 'with conditional imports' do
      it 'preserves conditional statements around imports' do
        content = <<~RUBY
          if RUBY_VERSION >= '2.7.0'
            require 'json'
          else
            require 'yaml'
          end

          unless defined?(JSON)
            require 'json/ext'
          end
        RUBY

        tempfile.write(content)
        tempfile.flush

        sorter.sort_and_format_imports
        result = File.read(tempfile.path)

        expect(result).to include("if RUBY_VERSION >= '2.7.0'")
        expect(result).to include("unless defined?(JSON)")
        expect(result).to include("require 'json'")
        expect(result).to include("require 'yaml'")
      end
    end
  end
end
