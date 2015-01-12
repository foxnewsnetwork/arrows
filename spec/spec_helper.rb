# TODO: move the specs in also lol
require 'pry'
require File.expand_path("../../lib/arrows", __FILE__)

module Composable
  def compose(f, g)
    -> (x) { f.(g.(x)) }
  end

  def *(g)
    compose(self, g)
  end
end
