class Arrows::Either
  attr_accessor :payload
  def initialize(good_or_evil, payload)
    @good = !!good_or_evil
    @payload = payload
  end
  def good?
    @good
  end
end