class Numeric
  def oppose
    -self
  end
end

class Money
  PENNIES = 100

  def floor
    self.class.new(cents - (cents % PENNIES))
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

module Enumerable
  def every
    each_with_index { |e,i| yield(i.zero?, i == size-1, *e) }
  end
end
