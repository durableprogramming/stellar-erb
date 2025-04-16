require 'test_helper'

module Stellar
  module Erb
    class ContextLinesMethodTest < Minitest::Test
      def setup
        @template_content = <<~ERB
          <html>
            <head>
              <title>Test Template</title>
            </head>
            <body>
              <h1>Hello, <%= name %></h1>
              <p>This is a test template with an error on line 7</p>
              <% raise RuntimeError, "Test error" %>
              <p>This content won't be rendered</p>
              <p>More content</p>
              <p>Even more content</p>
            </body>
          </html>
        ERB
        
        @template_path = create_temp_file("error_template.erb", @template_content)
        @error = Error.new("Test error", template_path: @template_path, line_number: 8)
      end
      
      def teardown
        remove_temp_file(@template_path)
      end
      
      def test_context_lines_returns_empty_array_when_template_path_is_nil
        error = Error.new("Test error", line_number: 8)
        assert_empty error.context_lines
      end
      
      def test_context_lines_returns_empty_array_when_line_number_is_nil
        error = Error.new("Test error", template_path: @template_path)
        assert_empty error.context_lines
      end
      
      def test_context_lines_returns_empty_array_when_file_does_not_exist
        error = Error.new("Test error", template_path: "non_existent_file.erb", line_number: 8)
        assert_empty error.context_lines
      end
      
      def test_context_lines_with_default_context
        lines = @error.context_lines
        
        assert_equal 11, lines.length

        assert_match(/^=>/, lines[5])  # Line 8 should be marked with =>
        assert_match(/^  /, lines[4])  # Other lines should be marked with spaces
        assert_match(/\d+: /, lines[0]) # Each line should have line number
        assert_match(/raise RuntimeError/, lines[5]) # Error line should contain error code
      end
      
      def test_context_lines_with_custom_context_size
        lines = @error.context_lines(2)
        
        assert_equal 5, lines.length
        assert_match(/^=>/, lines[2])  # Line 8 should be marked with =>
      end
      
      def test_context_lines_near_beginning_of_file
        error = Error.new("Test error", template_path: @template_path, line_number: 1)
        lines = error.context_lines(3)
        
        assert_equal 4, lines.length
        assert_match(/^=>/, lines[0])
      end
      
      def test_context_lines_near_end_of_file
        last_line = @template_content.lines.count
        error = Error.new("Test error", template_path: @template_path, line_number: last_line)
        lines = error.context_lines(3)
        
        assert_equal 4, lines.length
        assert_match(/^=>/, lines.last)
      end
      
      def test_context_lines_with_zero_context
        lines = @error.context_lines(0)
        
        assert_equal 1, lines.length
        assert_match(/^=> 8:/, lines[0])
      end
      
      def test_context_lines_handles_large_context_size
        lines = @error.context_lines(100)
        
        assert_equal @template_content.lines.count, lines.length
        assert_match(/^=>/, lines[7])
      end
      
      def test_context_lines_preserves_line_content
        lines = @error.context_lines
        
        assert_context_line_matches(@error, /raise RuntimeError/, 5)
        assert_context_line_matches(@error, /<\/html>/, 10)
      end

      def assert_context_line_matches(error, regex, line_numbers)
        expected_line_numbers = [line_numbers].flatten
        actual_line_numbers = []
        error.context_lines.each_with_index do |line, line_number|
          if regex.match?(line)
            actual_line_numbers.push line_number
          end
        end

        begin
          assert_equal expected_line_numbers, actual_line_numbers
        rescue Minitest::Assertion
          error.context_lines.each_with_index do |v,k|
            puts "#{k}\t\t#{v}"
          end
          raise
        end
      end
    end
  end
end
