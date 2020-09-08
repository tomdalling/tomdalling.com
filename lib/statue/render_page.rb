module Statue
  class RenderPage
    attr_reader :input_path, :destination_path

    def initialize(input_path: , destination_path:)
      @input_path = input_path
      @destination_path = destination_path
    end

    def description
      "Render page #{destination_path}"
    end

    def call(output_dir)
      page = Page.new(input_path.read)
      html = PageTemplate.new.call(page)
      output_dir.join(destination_path).write(html)
    end
  end
end
