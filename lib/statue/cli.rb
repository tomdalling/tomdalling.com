module Statue
  module CLI
    extend Dry::CLI::Registry
    register 'build', Build

    def self.run(argv=ARGV)
      Dry::CLI.new(self).call(arguments: argv)
    end
  end
end
