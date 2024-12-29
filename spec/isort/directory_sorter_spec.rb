require 'tmpdir'
require 'fileutils'
require 'isort'

RSpec.describe Isort::CLI do
  let(:test_directory) { Dir.mktmpdir } # Automatically managed temporary directory

  before do
    File.write(File.join(test_directory, 'file1.rb'), <<~RUBY)
      require 'json'
      include SomeModule
      require_relative 'b_file'
      require 'csv'
      extend AnotherModule
      require_relative 'a_file'
    RUBY

    File.write(File.join(test_directory, 'file2.rb'), <<~RUBY)
      require_relative 'z_file'
      require 'yaml'
      require 'csv'
      include AnotherModule
    RUBY
  end

  after do
    FileUtils.remove_entry(test_directory)
  end

  describe '#start' do
    context 'when a directory is specified' do
      it 'sorts and formats imports for all .rb files in the directory' do
        # Simulate passing the --directory argument to the CLI
        ARGV.replace(["--directory", test_directory])

        # Capture the output of CLI.start
        output = capture_stdout { Isort::CLI.start }

        # Verify the CLI output
        expect(output).to include("Sorted imports in 2 files in directory: #{test_directory}")

        # Verify the sorted content of the files
        file1_content = File.read(File.join(test_directory, 'file1.rb'))
        file2_content = File.read(File.join(test_directory, 'file2.rb'))

        expect(file1_content).to eq(<<~RUBY)
          require 'csv'
          require 'json'
          require_relative 'a_file'
          require_relative 'b_file'
          include SomeModule
          extend AnotherModule
        RUBY

        expect(file2_content).to eq(<<~RUBY)
          require 'csv'
          require 'yaml'
          require_relative 'z_file'
          include AnotherModule
        RUBY
      end
    end

    context 'when no .rb files are found in the directory' do
      before do
        FileUtils.rm_rf(test_directory)
        FileUtils.mkdir_p(test_directory)
        File.write(File.join(test_directory, 'file.txt'), "This is a text file.")
      end

      it 'does not modify any files and shows a valid message' do
        # Simulate passing the --directory argument to the CLI
        ARGV.replace(["--directory", test_directory])

        # Capture the output of CLI.start
        output = capture_stdout { Isort::CLI.start }

        # Verify the CLI output
        expect(output).to include("Sorted imports in 0 files in directory: #{test_directory}")

        # Verify that the non-Ruby file remains unchanged
        expect(File.read(File.join(test_directory, 'file.txt'))).to eq("This is a text file.")
      end
    end
  end

  # Helper method to capture standard output
  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
