module Statue
  module CLI
    def self.run(argv=ARGV)
      FileUtils.mkdir_p(Statue::OUTPUT_DIR)

      tree = TreeBuilder.build
      tree.outputs(Statue::INPUT_DIR).each do |output|
        puts "Writing #{output.destination}"
        output.write!(Statue::OUTPUT_DIR / output.destination)
      end
    end
  end
end
