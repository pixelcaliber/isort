require 'isort'

RSpec.describe Isort::FileSorter do
  let(:file_path) { "spec/fixtures/sample.rb" }
  let(:file_sorter) { described_class.new(file_path) }

  after do
    File.delete(file_path) if File.exist?(file_path)
  end

  describe '#sort_imports' do
    context 'with basic import sorting' do
      before do
        File.write(file_path, <<~RUBY)
          require 'json'
          require_relative 'b_file'
          require 'csv'
          include SomeModule
          require_relative 'a_file'
        RUBY
      end

      it "sorts imports alphabetically" do
        file_sorter.sort_and_format_imports

        expect(File.read(file_path)).to eq(<<~RUBY)
          require 'csv'
          require 'json'
          require_relative 'a_file'
          require_relative 'b_file'
          include SomeModule
        RUBY
      end

      it "maintains file content when imports are already sorted" do
        sorted_content = <<~RUBY
          require 'csv'
          require 'json'
          require_relative 'a_file'
          require_relative 'b_file'
          include SomeModule
        RUBY

        File.write(file_path, sorted_content)
        file_sorter.sort_and_format_imports

        expect(File.read(file_path)).to eq(sorted_content)
      end

      it "handles empty files" do
        File.write(file_path, "")
        file_sorter.sort_and_format_imports

        expect(File.read(file_path)).to eq("")
      end

      it "handles files with only comments" do
        content = <<~RUBY
          # This is a comment
          # Another comment
        RUBY

        File.write(file_path, content)
        file_sorter.sort_and_format_imports

        expect(File.read(file_path)).to eq(content)
      end

      it "preserves inline comments" do
        File.write(file_path, <<~RUBY)
          require 'json' # JSON parser
          require 'csv' # CSV handler
          require_relative 'b_file' # Custom file
          include SomeModule # Include module
          require_relative 'a_file' # Another file
        RUBY

        file_sorter.sort_and_format_imports

        expect(File.read(file_path)).to eq(<<~RUBY)
          require 'csv' # CSV handler
          require 'json' # JSON parser
          require_relative 'a_file' # Another file
          require_relative 'b_file' # Custom file
          include SomeModule # Include module
        RUBY
      end
    end
  end

  describe '#sort_and_format_imports' do
    context 'with advanced formatting' do
      before do
        File.write(file_path, <<~RUBY)
          require 'json'
          include SomeModule
          require_relative 'b_file'
          require 'csv'
          extend AnotherModule
          autoload :CSV, 'csv'
          using SomeRefinement
          require_relative 'a_file'
        RUBY
      end

      it "sorts and formats imports with section headers" do
        file_sorter.sort_and_format_imports

        expect(File.read(file_path)).to eq(<<~RUBY)
          require 'csv'
          require 'json'
          require_relative 'a_file'
          require_relative 'b_file'
          include SomeModule
          extend AnotherModule
          autoload :CSV, 'csv'
          using SomeRefinement
        RUBY
      end

      it "handles mixed case requires" do
        File.write(file_path, <<~RUBY)
          require 'JSON'
          require 'Csv'
          require 'stringio'
        RUBY

        file_sorter.sort_and_format_imports

        expect(File.read(file_path)).to eq(<<~RUBY)
          require 'Csv'
          require 'JSON'
          require 'stringio'
        RUBY
      end

      it "handles multiple includes of the same type" do
        File.write(file_path, <<~RUBY)
          include ModuleB
          require 'json'
          include ModuleA
          include ModuleC
        RUBY

        file_sorter.sort_and_format_imports

        expect(File.read(file_path)).to eq(<<~RUBY)
          require 'json'
          include ModuleA
          include ModuleB
          include ModuleC
        RUBY
      end

      # it "preserves spacing between different code sections" do
      #   File.write(file_path, <<~RUBY)
      #     require 'json'
      #
      #     include ModuleA
      #
      #     class MyClass
      #       extend ModuleB
      #     end
      #   RUBY
      #
      #   file_sorter.sort_and_format_imports

      #   expect(File.read(file_path)).to eq(<<~RUBY)
      #     require 'json'
      #
      #
      #     include ModuleA
      #     class MyClass
      #       extend ModuleB
      #     end
      #   RUBY
      # end

      # it "handles conditional requires" do
      #   File.write(file_path, <<~RUBY)
      #     if RUBY_VERSION >= '2.7'
      #       require 'json'
      #     else
      #       require 'oj'
      #     end
      #     require 'csv'
      #   RUBY
      #
      #   file_sorter.sort_and_format_imports
      #
      #   expect(File.read(file_path)).to eq(<<~RUBY)
      #     require 'csv'
      #     if RUBY_VERSION >= '2.7'
      #       require 'json'
      #     else
      #       require 'oj'
      #     end
      #   RUBY
      # end
    end
  end
  describe '#sort_and_format_imports' do
    it "preserves spacing between different code sections and nested extends" do
      File.write(file_path, <<~RUBY)
        require 'json'


        include ModuleA

        class MyClass
          extend ModuleB
        end
      RUBY

      file_sorter.sort_and_format_imports

      expect(File.read(file_path)).to eq(<<~RUBY)
        require 'json'
        include ModuleA
        
        
        
        class MyClass
          extend ModuleB
        end
      RUBY
    end

    it "handles conditional requires" do
      File.write(file_path, <<~RUBY)
        require 'csv'
        if RUBY_VERSION >= '2.7'
          require 'json'
        else
          require 'oj'
        end
      RUBY

      file_sorter.sort_and_format_imports

      expect(File.read(file_path)).to eq(<<~RUBY)
        require 'csv'
        if RUBY_VERSION >= '2.7'
          require 'json'
        else
          require 'oj'
        end
      RUBY
    end

    it "preserves nested modules and their imports" do
      File.write(file_path, <<~RUBY)
        require 'json'
        require 'csv'

        module OuterModule
          include ModuleA
          
          class InnerClass
            extend ModuleB
          end
        end
      RUBY

      file_sorter.sort_and_format_imports

      expect(File.read(file_path)).to eq(<<~RUBY)
        require 'csv'
        require 'json'

        module OuterModule
          include ModuleA
          
          class InnerClass
            extend ModuleB
          end
        end
      RUBY
    end
  end
end
