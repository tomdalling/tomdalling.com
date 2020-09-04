module Statue
  class Tree
    def outputs(input_dir)
      static_dir = input_dir / 'static'
      static_dir.glob('**/*').map do |input_path|
        Copy.new(
          source: input_path,
          destination: input_path.relative_path_from(static_dir),
        )
      end
    end
  end
end
