class Fixnum
  def oppose
    self - (self * 2)
  end
end

class Money
  alias old_format format
  def format(*rules)
    (r = old_format(rules)) == "free" ? "$0" : r
  end
end

