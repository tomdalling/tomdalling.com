module Statue
  class WebpackOutput
    attr_reader :filename

    def initialize(filename:, dependencies:)
      @filename = filename
      # TODO: dependencies
    end

    def description
      'Webpack'
    end

    def write_to(path)
      webpack_build
      FileUtils.cp(webpack_dist_path, path)
    end

    private

      def webpack_dist_path
        WEBPACK_DIR / 'dist' / filename
      end

      def webpack_build
        #TODO: ensure that this only gets run once
        system(
          "yarn run webpack &> dist/build_output.txt",
          chdir: WEBPACK_DIR,
          exception: true,
        )
      end
  end
end
