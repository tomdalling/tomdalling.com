Hanami::Controller.configure do
  handle_exceptions false
end

module Statue
  class DevServer
    include Hanami::Action

    attr_reader :outputs

    def initialize(outputs)
      @outputs = outputs
    end

    def call(params)
      rel_path = request_pathname(params)
      output_path = OUTPUT_DIR / rel_path
      output = outputs[rel_path]

      if output
        puts "Returning: #{rel_path}"
        rewrite(output: output, path: output_path)
        self.status = 200
        self.format = format_for(rel_path)
        self.body = output_path.read
      else
        self.status = 404
        self.body = "<h1>Path not found</h1><p>No output for: #{rel_path}</p>"
      end
    end

    private

      def rewrite(output:, path:)
        #TODO: only rewrite if changed since whenever
        output.write_to(path)
      end

      def format_for(path)
        case path.extname
        when '.html','.css','.jpg','.png', '.js'
          path.extname.delete_prefix('.').to_sym
        else
          fail "Unknown mime type for #{path}"
        end
      end

      def request_pathname(params)
        p = params.env.fetch('REQUEST_URI')
        p += 'index.html' if p.end_with?('/')
        p = p.delete_prefix('/')

        Pathname(p)
      end
  end
end
