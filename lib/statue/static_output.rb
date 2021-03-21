module Statue
  class StaticOutput
    attr_reader :source_file

    def initialize(source_file, allow_missing: false)
      @source_file = source_file
      @allow_missing = allow_missing
    end

    def allow_missing?
      @allow_missing
    end

    def description
      "Static"
    end

    def write_to(io)
      if source_file
        File.open(source_file.full_path, 'rb') do |f|
          IO.copy_stream(f, io)
        end
      elsif allow_missing?
        # this is fine
      else
        raise "Input file not found"
      end
    end

    def reset
      # nothing to reset
    end

    def modified_since?(mtime)
      source_file.modified_since?(mtime)
    end
  end
end
