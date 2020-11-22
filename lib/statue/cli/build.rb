module Statue
  class CLI::Build < Dry::CLI::Command
    desc "Builds the website"
    option :output,
      type: :path,
      default: Statue::DEFAULT_OUTPUT_DIR,
      desc: "The directory to place the build output"

    def call(output:)
      config = Statue::Build::Config.new(
        output_dir: Pathname.new(output).realpath,
        once?: true, #TODO: make option for this
      )
      Statue::Build.new(config).call
    end
  end
end
