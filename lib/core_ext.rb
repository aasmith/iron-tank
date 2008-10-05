class Fixnum
  def oppose
    self - (self * 2)
  end
end

class Money
  alias old_format format
  def format(*rules)
    (r = old_format(rules)) == "free" ? "$0" : r.commify
  end
end

class Array
  # Returns the first n elements, plus another element indicating how many
  # elements are left in the array.
  def cap(n)
    return [] if n.zero?
    return self unless size > n
    first(n-1) << self[n-1, size].size
  end
end

class String
  def commify
    reverse.gsub(/(\d\d\d)(?=\d)(?!\d*\.)/, '\1,').reverse
  end
end
