module Stellar
  module Erb
    class View
      attr_reader :template_path, :template_content, :locals
      
      def initialize(template_path, locals = {})
        @template_path = template_path
        @template_content = File.read(template_path)
        @locals = locals
        
      end
      
      def render(additional_locals = {})
        all_locals = locals.merge(additional_locals)
        erb = ::ERB.new(template_content)
        erb.result_with_hash(all_locals)
      rescue StandardError => e
        handle_error(e)
      end
      
      def self.render(template_path, locals = {})
        new(template_path, locals).render
      end
      
      private
      
      def handle_error(error)
        if error.is_a?(SyntaxError)
          raise Error, "Syntax error in template #{template_path}: #{error.message}"
        else
          backtrace = error.backtrace.select { |line| line.include?(template_path) }
          message = "Error rendering template #{template_path}: #{error.message}"
          error_with_context = Error.new(message)
          error_with_context.set_backtrace(backtrace.empty? ? error.backtrace : backtrace)
          raise error_with_context
        end
      end
    end
  end
end
