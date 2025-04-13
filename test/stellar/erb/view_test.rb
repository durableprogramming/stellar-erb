require "test_helper"

module Stellar
  module Erb
    class ViewTest < Minitest::Test
      def setup
        @template_dir = File.expand_path("../../fixtures", __dir__)
        @basic_template_path = File.join(@template_dir, "basic.erb")
        @complex_template_path = File.join(@template_dir, "complex.erb")
        @error_template_path = File.join(@template_dir, "error.erb")
        
        # Create fixture directory if it doesn't exist
        FileUtils.mkdir_p(@template_dir) unless Dir.exist?(@template_dir)
        
        # Create test templates
        File.write(@basic_template_path, "<h1>Hello, <%= name %>!</h1>")
        File.write(@complex_template_path, "<ul><% items.each do |item| %><li><%= item %></li><% end %></ul>")
        File.write(@error_template_path, "<%= undefined_variable %>")
      end
      
      def teardown
        # Clean up test templates
        FileUtils.rm_rf(@template_dir) if Dir.exist?(@template_dir)
      end
      
      def test_render_with_locals
        result = Stellar::Erb::View.render(@basic_template_path, name: "World")
        assert_equal "<h1>Hello, World!</h1>", result
      end
      
      def test_render_with_complex_locals
        result = Stellar::Erb::View.render(@complex_template_path, items: ["apple", "banana", "orange"])
        assert_equal "<ul><li>apple</li><li>banana</li><li>orange</li></ul>", result
      end
      
      def test_instance_render
        view = Stellar::Erb::View.new(@basic_template_path, name: "John")
        result = view.render
        assert_equal "<h1>Hello, John!</h1>", result
      end
      
      def test_instance_render_with_additional_locals
        view = Stellar::Erb::View.new(@basic_template_path)
        result = view.render(name: "Jane")
        assert_equal "<h1>Hello, Jane!</h1>", result
      end
      
      def test_instance_render_with_merged_locals
        view = Stellar::Erb::View.new(@basic_template_path, name: "John")
        result = view.render(name: "Jane")
        assert_equal "<h1>Hello, Jane!</h1>", result
      end
      
      def test_render_with_error
        error = assert_raises(Stellar::Erb::Error) do
          Stellar::Erb::View.render(@error_template_path)
        end
        
        assert_match(/undefined_variable/, error.message)
        assert_match(/#{@error_template_path}/, error.message)
      end
      
      def test_file_not_found
        assert_raises(Errno::ENOENT) do
          Stellar::Erb::View.render("non_existent_template.erb")
        end
      end
    end
  end
end
