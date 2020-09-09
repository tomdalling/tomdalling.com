module Statue
  class FileSet
    include Enumerable
    extend Forwardable
    def_delegator :files, :each

    attr_reader :base_dir

    def initialize(base_dir)
      @base_dir = base_dir
    end

    def files
      @files ||= Set.new(
        base_dir.glob('**/*').select(&:file?).map do |path|
          File.from_abs_path(path, base_dir: base_dir)
        end
      )
    end

    def descendants_of(relative_dir)
      relative_dir = Pathname.new(relative_dir)
      files.select { _1.path.descendant_of?(relative_dir) }
    end

    def glob(pattern)
      files.select do
        File.fnmatch?(
          pattern.to_s,
          _1.path.to_path,
          File::FNM_PATHNAME | File::FNM_EXTGLOB,
        )
      end
    end

    def [](relative_path)
      relative_path = Pathname.new(relative_path)
      files.find { _1.path == relative_path }
    end

    class File
      value_semantics do
        path RelativePathname
        base_dir AbsolutePathname
      end

      extend Forwardable
      def_delegators :full_path, *%i(read write delete)

      def self.from_abs_path(abs_path, base_dir:)
        new(
          base_dir: base_dir,
          path: abs_path.relative_path_from(base_dir),
        )
      end

      def full_path
        base_dir / path
      end

      def last_modified_at
        @last_modified_at ||= full_path.mtime
      end

      def modified_since?(mtime)
        last_modified_at > mtime
      end
    end
  end
end
