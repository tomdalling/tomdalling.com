module Statue
  class StaticOutput
    attr_reader :source_file

    def initialize(source_file)
      @source_file = source_file
    end

    def description
      "Static"
    end

    def write_to(io)
      File.open(source_file.full_path, 'rb') do |f|
        IO.copy_stream(f, io)
      end
    end

    def modified_since?(mtime)
      source_file.modified_since?(mtime)
    end
  end
end
