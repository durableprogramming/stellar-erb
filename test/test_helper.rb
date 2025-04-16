# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  enable_coverage :branch
  add_filter "/test/"
end

require "minitest"
require "minitest/autorun"
require "fileutils"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "stellar/erb"

module TestHelpers
  def create_temp_file(name, content)
    path = File.join(Dir.tmpdir, "stellar_erb_test_#{name}")
    File.write(path, content)
    path
  end

  def remove_temp_file(path)
    File.unlink(path) if File.exist?(path)
  end
end

module Minitest
  class Test
    include TestHelpers
  end
end
