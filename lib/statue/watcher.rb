module Statue
  class Watcher
    attr_reader :dir

    def initialize(dir)
      @dir = dir
      @last_mtimes = {}
    end

    def next_changeset
      old_mtimes = @last_mtimes
      new_mtimes = @last_mtimes = mtimes

      added = new_mtimes.keys - old_mtimes.keys
      removed = old_mtimes.keys - new_mtimes.keys
      survived = new_mtimes.keys & old_mtimes.keys
      modified = survived.select { new_mtimes[_1] > old_mtimes[_1] }

      Changeset.new(
        dir: dir,
        changes: (
          added.map { Change.added(_1) } +
          removed.map { Change.removed(_1) } +
          modified.map { Change.modified(_1) }
        )
      )
    end

    private

      def mtimes
        dir.glob('**/*').select(&:file?).reduce({}) do |result, path|
          result.merge(path => path.mtime)
        end
      end
  end
end
