require "test_helper"

module Stellar
  module Erb
    class BindingTest < Minitest::Test
      def test_get_binding_defines_methods_for_locals
        locals = { name: "John", age: 30 }
        binding_obj = Binding.new(locals)
        
        # Get the binding and evaluate methods
        b = binding_obj.get_binding
        
        assert_equal "John", eval("name", b)
        assert_equal 30, eval("age", b)
      end
      
      def test_method_missing_provides_access_to_locals
        locals = { name: "John", items: [1, 2, 3] }
        binding_obj = Binding.new(locals)
        
        assert_equal "John", binding_obj.name
        assert_equal [1, 2, 3], binding_obj.items
      end
      
      def test_method_missing_raises_error_for_undefined_locals
        binding_obj = Binding.new(name: "John")
        
        assert_raises(NoMethodError) do
          binding_obj.undefined_method
        end
      end
      
      def test_respond_to_missing_returns_true_for_defined_locals
        locals = { name: "John", age: 30 }
        binding_obj = Binding.new(locals)
        
        assert binding_obj.respond_to?(:name)
        assert binding_obj.respond_to?(:age)
        refute binding_obj.respond_to?(:undefined_method)
      end
      
      def test_locals_are_accessible
        locals = { a: 1, b: 2 }
        binding_obj = Binding.new(locals)
        
        assert_equal locals, binding_obj.locals
      end
    end
  end
end
