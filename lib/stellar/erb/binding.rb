module Stellar
  module Erb
    class Binding
      attr_reader :locals
      
      def initialize(locals = {})
        @locals = locals
      end
      
      def get_binding
        locals.each do |key, value|
          singleton_class.class_eval do
            define_method(key) { value }
          end
        end
        binding
      end
      
      def method_missing(method_name, *args, &block)
        if locals.key?(method_name)
          locals[method_name]
        else
          super
        end
      end
      
      def respond_to_missing?(method_name, include_private = false)
        locals.key?(method_name) || super
      end
    end
  end
end
