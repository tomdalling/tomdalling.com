class Pathname
  def descendant_of?(other)
    other = Pathname(other)
    descend.any? { _1 == other }
  end
end
