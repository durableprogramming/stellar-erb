require 'test_helper'

module Stellar
  module Erb
    class ToSMethodTest < Minitest::Test
      def setup
        @template_path = "template.erb"
        @line_number = 42
        @message = "Test error message"
      end

      def test_to_s_with_template_path_and_line_number
        error = Error.new(@message, template_path: @template_path, line_number: @line_number)
        expected = "#{@message} in '#{@template_path}' on line #{@line_number}"
        assert_equal expected, error.to_s
      end

      def test_to_s_with_template_path_only
        error = Error.new(@message, template_path: @template_path)
        expected = "#{@message} in '#{@template_path}'"
        assert_equal expected, error.to_s
      end

      def test_to_s_with_no_template_or_line_number
        error = Error.new(@message)
        assert_equal @message, error.to_s
      end

      def test_to_s_with_line_number_but_no_template_path
        error = Error.new(@message, line_number: @line_number)
        assert_equal @message, error.to_s
      end

      def test_to_s_with_empty_message
        error = Error.new("", template_path: @template_path, line_number: @line_number)
        expected = " in '#{@template_path}' on line #{@line_number}"
        assert_equal expected, error.to_s
      end

      def test_to_s_with_nil_message
        error = Error.new(nil, template_path: @template_path, line_number: @line_number)
        expected = "Stellar::Erb::Error in '#{@template_path}' on line #{@line_number}"
        assert_equal expected, error.to_s
      end

      def test_to_s_with_complex_message
        complex_message = "Error with \"quotes\" and 'apostrophes'"
        error = Error.new(complex_message, template_path: @template_path, line_number: @line_number)
        expected = "#{complex_message} in '#{@template_path}' on line #{@line_number}"
        assert_equal expected, error.to_s
      end

      def test_to_s_inheritance
        subclass = Class.new(Error)
        error = subclass.new(@message, template_path: @template_path, line_number: @line_number)
        expected = "#{@message} in '#{@template_path}' on line #{@line_number}"
        assert_equal expected, error.to_s
      end

      def test_to_s_with_original_error
        original = RuntimeError.new("Original error")
        error = Error.new(@message, 
                          template_path: @template_path, 
                          line_number: @line_number, 
                          original_error: original)
        expected = "#{@message} in '#{@template_path}' on line #{@line_number}"
        assert_equal expected, error.to_s
      end

      def test_to_s_with_template_path_containing_special_characters
        special_path = "path/with/special_chars-!@#$.erb"
        error = Error.new(@message, template_path: special_path, line_number: @line_number)
        expected = "#{@message} in '#{special_path}' on line #{@line_number}"
        assert_equal expected, error.to_s
      end
    end
  end
end
