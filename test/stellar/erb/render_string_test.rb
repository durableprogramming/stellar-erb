# frozen_string_literal: true

require "test_helper"

module Stellar
  module Erb
    class RenderStringTest < Minitest::Test
      def test_render_string_with_locals
        result = Stellar::Erb.render_string("<h1>Hello, <%= name %>!</h1>", name: "World")
        assert_equal "<h1>Hello, World!</h1>", result
      end

      def test_render_string_with_complex_locals
        template = "<ul><% items.each do |item| %><li><%= item %></li><% end %></ul>"
        result = Stellar::Erb.render_string(template, items: %w[apple banana orange])
        assert_equal "<ul><li>apple</li><li>banana</li><li>orange</li></ul>", result
      end

      def test_render_string_without_locals
        result = Stellar::Erb.render_string("<p>Static content</p>")
        assert_equal "<p>Static content</p>", result
      end

      def test_render_string_with_error
        error = assert_raises(TypeError) do
          Stellar::Erb.render_string("<%= undefined_variable %>")
        end
      end

      def test_render_string_with_syntax_error
        error = assert_raises(SyntaxError) do
          Stellar::Erb.render_string("<% if true %>Unclosed if statement")
        end

        assert_match(/syntax error/, error.message.downcase)
      end
    end
  end
end
