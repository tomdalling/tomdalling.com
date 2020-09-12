ValueSemantics.monkey_patch!

class Pathname
  def descendant_of?(other)
    other = Pathname(other)
    descend.any? { _1 == other }
  end
end

class Addressable::URI
  def with_query(query)
    dup.tap do |uri|
      uri.query = query
    end
  end

  def /(other)
    join(other)
  end
end
