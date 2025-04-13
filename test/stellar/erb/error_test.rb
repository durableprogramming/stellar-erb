require "test_helper"

module Stellar
  module Erb
    class ErrorTest < Minitest::Test
      def setup
        @template_path = File.expand_path("fixtures/test_template.erb", __dir__)
        @error_message = "test error message"
        @line_number = 42
      end
      
      def test_initialize
        error = Error.new(@error_message, template_path: @template_path, line_number: @line_number)
        assert_equal @template_path, error.template_path
        assert_equal @line_number, error.line_number
      end
      
      def test_to_s_with_template_and_line
        error = Error.new(@error_message, template_path: @template_path, line_number: @line_number)
        expected = "#{@error_message} in '#{@template_path}' on line #{@line_number}"
        assert_equal expected, error.to_s
      end
      
      def test_to_s_with_template_only
        error = Error.new(@error_message, template_path: @template_path)
        expected = "#{@error_message} in '#{@template_path}'"
        assert_equal expected, error.to_s
      end
      
      def test_to_s_without_template
        error = Error.new(@error_message)
        assert_equal @error_message, error.to_s
      end
      
      def test_wrap_error
        original = RuntimeError.new(@error_message)
        wrapped = Error.wrap(original, template_path: @template_path)
        
        assert_instance_of Error, wrapped
        assert_equal original, wrapped.original_error
        assert_equal @template_path, wrapped.template_path
      end
      
      def test_wrap_already_wrapped_error
        original = Error.new(@error_message)
        wrapped = Error.wrap(original)
        
        assert_same original, wrapped
      end
      
      def test_extract_line_number
        error = RuntimeError.new
        error.set_backtrace(["#{@template_path}:#{@line_number}:in `method'"])
        
        line_number = Error.extract_line_number(error, @template_path)
        assert_equal @line_number, line_number
      end
      
      def test_extract_line_number_no_match
        error = RuntimeError.new
        error.set_backtrace(["some/other/file.rb:10:in `method'"])
        
        line_number = Error.extract_line_number(error, @template_path)
        assert_nil line_number
      end
      
      def test_context_lines
        File.stub :exist?, true do
          File.stub :readlines, ["line 1\n", "line 2\n", "line 3\n", "line 4\n", "line 5\n"] do
            error = Error.new("Error", template_path: @template_path, line_number: 3)
            expected = [
              "   1: line 1",
              "   2: line 2",
              "=> 3: line 3",
              "   4: line 4",
              "   5: line 5"
            ]
            assert_equal expected, error.context_lines
          end
        end
      end
      
      def test_context_lines_at_beginning
        File.stub :exist?, true do
          File.stub :readlines, ["line 1\n", "line 2\n", "line 3\n", "line 4\n", "line 5\n"] do
            error = Error.new("Error", template_path: @template_path, line_number: 1)
            expected = [
              "=> 1: line 1",
              "   2: line 2",
              "   3: line 3",
              "   4: line 4",
              "   5: line 5"
            ]
            assert_equal expected, error.context_lines
          end
        end
      end
      
      def test_context_lines_with_nonexistent_file
        File.stub :exist?, false do
          error = Error.new("Error", template_path: @template_path, line_number: 3)
          assert_empty error.context_lines
        end
      end
    end
  end
end
