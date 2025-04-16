require 'test_helper'

module Stellar
  module Erb
    class ExtractLineNumberMethodTest < Minitest::Test
      def setup
        @template_path = 'test_template.erb'
        @error = StandardError.new('Test error')
        @error_with_backtrace = StandardError.new('Error with backtrace')
        @error_with_backtrace.set_backtrace([
          "/path/to/some/file.rb:10:in `method_a'",
          "#{@template_path}:42:in `render'",
          "/another/path.rb:15:in `method_b'"
        ])
      end

      def test_returns_nil_when_template_path_is_nil
        assert_nil Error.extract_line_number(@error_with_backtrace, nil)
      end

      def test_returns_nil_when_backtrace_is_nil
        assert_nil Error.extract_line_number(@error, @template_path)
      end

      def test_returns_nil_when_template_path_not_in_backtrace
        error = StandardError.new('Error')
        error.set_backtrace(["/some/other/file.rb:20:in `method'"])

        assert_nil Error.extract_line_number(error, @template_path)
      end

      def test_extracts_correct_line_number_from_backtrace
        result = Error.extract_line_number(@error_with_backtrace, @template_path)

        assert_equal 42, result
      end

      def test_handles_complex_backtrace
        error = StandardError.new('Complex error')
        error.set_backtrace([
          "/path/file.rb:5:in `method'",
          "#{@template_path}:123:in `block (2 levels) in render'",
          "/other/path.rb:10:in `call'"
        ])

        result = Error.extract_line_number(error, @template_path)

        assert_equal 123, result
      end

      def test_handles_backtrace_with_no_line_numbers
        error = StandardError.new('Error without line numbers')
        error.set_backtrace([
          "/path/file.rb in `method'",
          "#{@template_path} in `render'",
          "/other/path.rb in `call'"
        ])

        assert_nil Error.extract_line_number(error, @template_path)
      end

      def test_handles_multiple_occurrences_of_template_in_backtrace
        error = StandardError.new('Multiple template occurrences')
        error.set_backtrace([
          "/path/file.rb:5:in `method'",
          "#{@template_path}:123:in `partial'",
          "/other/path.rb:10:in `call'",
          "#{@template_path}:456:in `render'"
        ])

        # Should return the first occurrence
        result = Error.extract_line_number(error, @template_path)

        assert_equal 123, result
      end

      def test_handles_template_path_with_special_characters
        special_path = "path/with-special_chars!@#$.erb"
        error = StandardError.new('Special characters in path')
        error.set_backtrace(["#{special_path}:78:in `render'"])

        result = Error.extract_line_number(error, special_path)

        assert_equal 78, result
      end

      def test_handles_empty_backtrace
        error = StandardError.new('Empty backtrace')
        error.set_backtrace([])

        assert_nil Error.extract_line_number(error, @template_path)
      end
    end
  end
end
