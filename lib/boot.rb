# require standard libraries
require 'pathname'
require 'forwardable'
require 'date'
require 'strscan'
require 'time'

# require gems
ENV['BUNDLE_GEMFILE'] ||= Pathname(__dir__).parent.join('Gemfile').to_path
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# setup zetwork loader
Zeitwerk::Loader.new.tap do |loader|
  loader.inflector.inflect(
    'cli' => 'CLI',
    'generate_rss' => 'GenerateRSS',
    'rss' => 'RSS',
    'edn' => 'EDN',
  )
  loader.push_dir(__dir__)
  loader.setup # ready!
end

# boot stuff that the codebase expects to be globally available
ValueSemantics.monkey_patch!