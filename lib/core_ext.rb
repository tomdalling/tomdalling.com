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
    join(
      case other
      when Pathname then other.to_path
      when String then other
      else fail("Can't join to URL: #{other.inspect}")
      end
    )
  end
end
