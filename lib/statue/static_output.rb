module Statue
  class StaticOutput
    attr_reader :source_file

    def initialize(source_file)
      @source_file = source_file
    end

    def description
      "Static"
    end

    def write_to(dest_path)
      FileUtils.cp(source_file.full_path, dest_path)
    end

    def modified_since?(mtime)
      source_file.modified_since?(mtime)
    end
  end
end
