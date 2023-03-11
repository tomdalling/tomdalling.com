module Statue
  class DevServer < Hanami::Action
    attr_reader :outputs

    def initialize(outputs:)
      @outputs = outputs
      super()
    end

    def handle(req, resp)
      path = request_pathname(req.params)
      output = outputs[path]

      if output
        puts "Rendering #{path}"

        resp.status = 200
        resp.format = path.extname.delete_prefix('.').to_sym
        resp.body = render(output)
      else
        resp.status = 404
        resp.body = "<h1>Path not found</h1><p>No output for: #{path}</p>"
      end
    end

    private

      def render(output)
        #TODO: only rerender if changed since whenever
        output.reset
        body_io = StringIO.new("", 'wb')
        output.write_to(body_io)
        body_io.string
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
