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

    def write_to(io)
      webpack_build
      File.open(webpack_dist_path, 'rb') do |f|
        IO.copy_stream(f, io)
      end
    end

    def reset
      # TODO: implement this after adding caching to `#webpack_build`
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
