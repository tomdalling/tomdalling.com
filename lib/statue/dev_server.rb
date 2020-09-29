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
      path = request_pathname(params)
      output = outputs[path]

      if output
        puts "Rendering #{path}"

        self.status = 200
        self.format = format_for(path)
        self.body = render(output)
      else
        self.status = 404
        self.body = "<h1>Path not found</h1><p>No output for: #{path}</p>"
      end
    end

    private

      def render(output)
        #TODO: only rerender if changed since whenever
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
