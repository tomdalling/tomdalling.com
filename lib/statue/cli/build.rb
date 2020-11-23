module Statue
  class CLI::Build < Dry::CLI::Command
    desc "Builds the website"
    option :output,
      type: :path,
      default: 'output',
      desc: "The directory to place the build output"

    def call(output:)
      output_dir = Pathname.new(output)
      FileUtils.mkdir_p(output_dir)

      config = Statue::Build::Config.new(
        output_dir: output_dir.realpath,
        once?: true, #TODO: make option for this
      )
      Statue::Build.new(config).call
    end
  end
end
