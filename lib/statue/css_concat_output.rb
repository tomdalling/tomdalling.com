module Statue
  class CSSConcatOutput
    attr_reader :inputs

    def initialize(inputs)
      @inputs = inputs
    end

    def description
      'CSS Concat'
    end

    def write_to(io)
      inputs.sort_by(&:path).each do |i|
        io.write("/**** #{i.path.basename} ****/\n")
        io.write(i.read)
        io.write("\n")
      end
    end

    def reset
      # do nothing
    end

    def modified_since?(mtime)
      inputs.any? { _1.modified_since?(mtime) }
    end
  end
end
