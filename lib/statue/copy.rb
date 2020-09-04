module Statue
  class Copy
    value_semantics do
      source AbsolutePathname
      destination RelativePathname
    end

    def description
      "Copy #{destination}"
    end

    def call(output_dir)
      path = output_dir / destination
      FileUtils.mkdir_p(path.dirname)
      FileUtils.cp(source, path)
    end
  end
end
