module Statue
  class CLI::Build < Dry::CLI::Command
    desc "Builds the website"
    option :output,
      type: :path,
      default: 'output',
      desc: "The directory to place the build output"
    option :include_drafts,
      type: :boolean,
      default: false,
      desc: "Include draft blog posts"

    def call(output:, include_drafts:)
      output_dir = Pathname.new(output)
      FileUtils.mkdir_p(output_dir)

      config = Statue::Build::Config.new(
        output_dir: output_dir.realpath,
        once?: true, #TODO: make option for this
        include_drafts?: include_drafts,
      )
      Statue::Build.new(config).call
    end
  end
end
