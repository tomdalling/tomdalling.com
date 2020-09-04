module Statue
  class Delete
    value_semantics do
      destination RelativePathname
    end

    def description
      "Delete #{destination}"
    end

    def call(output_dir)
      FileUtils.rm_f(output_dir / destination)
    end
  end
end
