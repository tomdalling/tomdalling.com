module Statue
  class Copy
    value_semantics do
      source AbsolutePathname
      destination RelativePathname
    end

    def write!(path)
      FileUtils.mkdir_p(path.dirname)
      FileUtils.cp(source, path)
    end
  end
end
