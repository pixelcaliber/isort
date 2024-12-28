require 'isort'

RSpec.describe Isort::FileSorter do
  let(:file_path) { "spec/fixtures/sample.rb" }
  let(:file_sorter) { described_class.new(file_path) }

  before do
    # Create a sample file with unsorted imports
    File.write(file_path, <<~RUBY)
      require 'json'
      require_relative 'b_file'
      require 'csv'
      include SomeModule
      require_relative 'a_file'
    RUBY
  end

  after do
    # Clean up the sample file
    File.delete(file_path) if File.exist?(file_path)
  end

  it "sorts imports alphabetically" do
    # Run the sorting functionality
    file_sorter.sort_imports

    # Read the file content after sorting
    sorted_content = File.read(file_path)

    # Define the expected output
    expected_content = <<~RUBY
      include SomeModule
      require 'csv'
      require 'json'
      require_relative 'a_file'
      require_relative 'b_file'
    RUBY

    # Assert that the sorted content matches the expected output
    expect(sorted_content).to eq(expected_content)
  end
  it "does not change already sorted imports" do
    # Create a sample file with already sorted imports
    File.write(file_path, <<~RUBY)
    include SomeModule
    require 'csv'
    require 'json'
    require_relative 'a_file'
    require_relative 'b_file'
  RUBY

    # Run the sorting functionality
    file_sorter.sort_imports

    # Read the file content after sorting
    sorted_content = File.read(file_path)

    # Assert that the content remains unchanged
    expect(sorted_content).to eq(<<~RUBY)
    include SomeModule
    require 'csv'
    require 'json'
    require_relative 'a_file'
    require_relative 'b_file'
  RUBY
  end

end
