# require gems
ENV['BUNDLE_GEMFILE'] ||= File.expand_path("#{__dir__}/../Gemfile")
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# require standard libraries
require 'pathname'
require 'forwardable'
require 'date'
require 'strscan'
require 'time'
require 'json'

# setup zeitwork loader
module Inflector
  ACRONYMS = %w(CLI DOM RSS EDN OpenGL)

  def self.camelize(basename, _abspath)
    @dry_inflector ||= Dry::Inflector.new { _1.acronym(*ACRONYMS) }
    @dry_inflector.camelize(basename)
  end
end

Zeitwerk::Loader.new.tap do |loader|
  loader.inflector = Inflector
  loader.push_dir(__dir__)
  loader.setup
end

# boot stuff that the codebase expects to be globally available
require_relative 'core_ext'
