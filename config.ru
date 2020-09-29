require_relative 'lib/boot'

BetterErrors::Middleware.allow_ip! "0.0.0.0/0"
BetterErrors.application_root = __dir__
use BetterErrors::Middleware

puts ">>> Booting outputs..."
t = Time.now
inputs = Statue::FileSet.new(Statue::INPUT_DIR)
outputs = Statue::Outputs.for(inputs)
puts "<<< Outputs booted in #{Time.now-t} seconds"

run Statue::DevServer.new(outputs: outputs)
