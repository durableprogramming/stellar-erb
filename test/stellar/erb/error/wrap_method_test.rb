# frozen_string_literal: true

require "test_helper"

module Stellar
  module Erb
    class WrapMethodTest < Minitest::Test
      def setup
        @template_path = "test_template.erb"
        @standard_error = StandardError.new("Something went wrong")
        @name_error = NameError.new("undefined local variable or method `undefined_var'")
        @syntax_error = SyntaxError.new("syntax error, unexpected end-of-input")
      end

      def test_wrap_returns_error_if_already_stellar_erb_error
        stellar_error = Stellar::Erb::Error.new("Original error")
        result = Stellar::Erb::Error.wrap(stellar_error)

        assert_equal stellar_error, result
        assert_same stellar_error, result
      end

      def test_wrap_creates_new_error_from_standard_error
        result = Stellar::Erb::Error.wrap(@standard_error, template_path: @template_path)

        assert_instance_of Stellar::Erb::Error, result
        assert_equal "#{@standard_error.message} in '#{@template_path}'", result.message
        assert_equal @template_path, result.template_path
        assert_equal @standard_error, result.original_error
      end

      def test_wrap_preserves_original_error_message
        result = Stellar::Erb::Error.wrap(@name_error, template_path: @template_path)

        assert_includes result.to_s, @name_error.message
      end

      def test_wrap_includes_template_path_in_error_message
        result = Stellar::Erb::Error.wrap(@standard_error, template_path: @template_path)

        assert_includes result.to_s, @template_path
      end

      def test_wrap_with_no_template_path
        result = Stellar::Erb::Error.wrap(@standard_error)

        assert_instance_of Stellar::Erb::Error, result
        assert_nil result.template_path
        assert_equal @standard_error, result.original_error
        assert_equal @standard_error.message, result.message
      end

      def test_wrap_attempts_to_extract_line_number
        error_with_backtrace = StandardError.new("Error with line number")
        error_with_backtrace.set_backtrace(["#{@template_path}:42:in `block in whatever'"])

        result = Stellar::Erb::Error.wrap(error_with_backtrace, template_path: @template_path)

        assert_equal 42, result.line_number
        assert_includes result.to_s, "line 42"
      end

      def test_wrap_handles_missing_line_number_in_backtrace
        error_with_backtrace = StandardError.new("Error without line number")
        error_with_backtrace.set_backtrace(["some_other_file.rb:10:in `method'"])

        result = Stellar::Erb::Error.wrap(error_with_backtrace, template_path: @template_path)

        assert_nil result.line_number
      end

      def test_wrap_handles_nil_backtrace
        error_without_backtrace = StandardError.new("Error without backtrace")

        result = Stellar::Erb::Error.wrap(error_without_backtrace, template_path: @template_path)

        assert_nil result.line_number
        refute_includes result.to_s, "line"
      end

      def test_wrap_handles_complex_backtraces
        complex_error = StandardError.new("Complex error")
        complex_error.set_backtrace([
          "/some/path/file.rb:5:in `method'",
          "#{@template_path}:123:in `block (2 levels) in render'",
          "/another/path.rb:10:in `call'"
        ])

        result = Stellar::Erb::Error.wrap(complex_error, template_path: @template_path)

        assert_equal 123, result.line_number
        assert_includes result.to_s, "line 123"
      end

      def test_wrap_with_syntax_error
        result = Stellar::Erb::Error.wrap(@syntax_error, template_path: @template_path)

        assert_instance_of Stellar::Erb::Error, result
        assert_equal @syntax_error, result.original_error
        assert_includes result.to_s, "syntax error"
      end

      def test_extract_line_number_returns_nil_for_nil_template_path
        result = Stellar::Erb::Error.extract_line_number(@standard_error, nil)
        assert_nil result
      end

      def test_extract_line_number_returns_nil_for_nil_backtrace
        error_without_backtrace = StandardError.new
        result = Stellar::Erb::Error.extract_line_number(error_without_backtrace, @template_path)
        assert_nil result
      end

      def test_extract_line_number_returns_nil_when_template_not_in_backtrace
        error = StandardError.new
        error.set_backtrace(["other_file.rb:10:in `method'"])

        result = Stellar::Erb::Error.extract_line_number(error, @template_path)
        assert_nil result
      end

      def test_extract_line_number_finds_correct_line_in_backtrace
        error = StandardError.new
        error.set_backtrace([
          "other_file.rb:10:in `method'",
          "#{@template_path}:42:in `block in render'",
          "another_file.rb:20:in `call'"
        ])

        result = Stellar::Erb::Error.extract_line_number(error, @template_path)
        assert_equal 42, result
      end
    end
  end
end
