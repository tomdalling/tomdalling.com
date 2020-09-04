module Statue
  class Copy
    value_semantics do
      source AbsolutePathname
      destination RelativePathname
    end

    def write!(path)
      FileUtils.cp(source, path)
    end
  end
end
