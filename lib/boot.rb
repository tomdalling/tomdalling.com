# require standard libraries
require 'pathname'
require 'forwardable'
require 'date'
require 'strscan'
require 'time'
require 'json'

# require gems
ENV['BUNDLE_GEMFILE'] ||= Pathname(__dir__).parent.join('Gemfile').to_path
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# setup zeitwork loader
module Inflector
  ACRONYMS = %w(CLI DOM RSS EDN)

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
ValueSemantics.monkey_patch!
require_relative 'core_ext'
