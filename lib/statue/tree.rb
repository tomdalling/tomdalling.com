module Statue
  class Tree
    def actions_for(changeset)
      static_dir = changeset.dir / 'static'
      changeset.glob(static_dir/'**/*').map do |change|
        if change.added? || change.modified?
          Copy.new(
            source: change.path,
            destination: change.path.relative_path_from(static_dir),
          )
        elsif change.removed?
          Delete.new(
            destination: change.path.relative_path_from(static_dir),
          )
        else
          nil
        end
      end.compact
    end
  end
end
