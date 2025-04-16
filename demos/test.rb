require_relative '../lib/stellar/erb'
require_relative '../lib/stellar/erb/view'

# Create a simple template file to test
File.write('demo_template.erb', <<~ERB)
  <html>
    <head>
      <title><%= page_title %></title>
    </head>
    <body>
      <h1>Hello, <%= name %>!</h1>
      <% if items && !items.empty? %>
        <ul>
          <% items.each do |item| %>
            <li><%= item %></li>
          <% end %>
        </ul>
      <% else %>
        <p>No items found.</p>
      <% end %>
      
      <footer>Current time: <%= Time.now %></footer>
    </body>
  </html>
ERB

# Basic usage example
puts "=== Basic Usage ==="
result = Stellar::Erb::View.render('demo_template.erb', 
  page_title: 'Welcome to Stellar::Erb',
  name: 'World',
  items: ['Ruby', 'ERB', 'Templates']
)
puts result
puts "\n\n"

# Using a view instance
puts "=== View Instance ==="
view = Stellar::Erb::View.new('demo_template.erb', name: 'Developer')
html = view.render(page_title: 'Reusing View Instance', items: ['Easy', 'Safe', 'Flexible'])
puts html
puts "\n\n"

# Error handling example
puts "=== Error Handling ==="
begin
  # Create a template with an error
  File.write('error_template.erb', '<%= undefined_variable %>')
  
  Stellar::Erb::View.render('error_template.erb')
rescue Stellar::Erb::Error => e
  pp e
  pp e.line_number
  puts "Caught error: #{e.message}"
  puts "Context lines:"
  puts e.context_lines rescue puts "(Context lines not available)"
end

# Clean up
File.unlink('demo_template.erb')
File.unlink('error_template.erb') if File.exist?('error_template.erb')
