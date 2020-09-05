module Statue
  class Changeset
    value_semantics do
      dir AbsolutePathname
      changes ArrayOf(Change)
    end

    def glob(pattern)
      changes.select do
        File.fnmatch?(pattern.to_s, _1.path.to_path, File::FNM_PATHNAME | File::FNM_EXTGLOB)
      end
    end

    extend Forwardable
    def_delegators :changes,
      *%i(any? empty?)
  end
end
