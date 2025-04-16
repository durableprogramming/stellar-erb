require_relative "erb/version"
require_relative "erb/error"
require_relative "erb/view"
require "erb"

module Stellar
  module Erb
    class Error < StandardError; end
    
    # Shortcut method for rendering templates
    def self.render(template_path, locals = {})
      View.render(template_path, locals)
    end
  end
end
