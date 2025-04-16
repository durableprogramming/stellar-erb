# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test]

require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/{test_*,*_test}.rb"]
end
