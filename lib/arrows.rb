require "arrows/version"

module Arrows
  require 'arrows/either'
  require 'arrows/proc'
  class << self
    def fork(f,g)
      Arrows::Proc.new do |either|
        either.good? ? f[either.payload] : g[either.payload]
      end
    end
    def concurrent(f,g)
      Arrows::Proc.new do |args| 
        [f[args.first], g[args.last]]
      end
    end
    def fanout(f,g)
      Arrows::Proc.new { |args| [f[args], g[args]] }
    end
    def compose(f,g)
      Arrows::Proc.new { |args| g[f[args]] }
    end
    def fmap(xs, f)
      Arrows::Proc.new { |args| xs[args].map { |x| f[x] }  }
    end
    def good(x)
      return x if x.respond_to?(:good?) && x.respond_to?(:payload)
      Arrows::Either.new true, x
    end
    def evil(x)
      return x if x.respond_to?(:good?) && x.respond_to?(:payload)
      Arrows::Either.new false, x
    end 
    def lift(x)
      return x if arrow_like? x
      return wrap_proc x if proc_like? x
      Arrows::Proc.new { |args| x }
    end
    def arrow_like?(x)
       proc_like?(x) && x.arity == 1 && x.respond_to?(:>=) && x.respond_to?(:>>)
    end
    def proc_like?(x)
      x.respond_to?(:call) && x.respond_to?(:arity)
    end
    def wrap_proc(f)
      Arrows::Proc.new do |args|
        f[args]
      end
    end
  end
  ID = lift -> (x) { x }
end
