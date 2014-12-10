require "arrows/version"

module Arrows
  ID = -> (x) { x }
  class Either
    attr_accessor :payload
    def initialize(good_or_evil, payload)
      @good = !!good_or_evil
      @payload = payload
    end
    def good?
      @good
    end
  end
  class << self
    def fork(f,g)
      Arrows::Proc.new do |either|
        either.good? ? f[*either.payload] : g[*either.payload]
      end
    end
    def concurrent(f,g)
      Arrows::Proc.new do |*args| 
        [f[*args.first], g[*args.last]]
      end
    end
    def fanout(f,g)
      Arrows::Proc.new { |*args| [f[*args], g[*args]] }
    end
    def compose(f,g)
      Arrows::Proc.new { |*args| g[*f[*args]] }
    end
    def fmap(xs, f)
      Arrows::Proc.new { |*args| xs[*args].map { |*x| f[*x] }  }
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
      Arrows::Proc.new { |*args| x }
    end
    def arrow_like?(x)
       proc_like?(x) && x.arity == -1
    end
    def proc_like?(x)
      x.respond_to?(:call) && x.respond_to?(:arity)
    end
    def wrap_proc(f)
      Arrows::Proc.new do |*args|
        f[*args]
      end
    end
  end
  class Proc < ::Proc
    # applicative fmap
    def >=(f)
      Arrows.fmap self, Arrows.lift(f)
    end

    # standard composition
    def >>(f)
      Arrows.compose self, Arrows.lift(f)
    end

    # fanout composition
    def /(f)
      Arrows.fanout self, Arrows.lift(f)
    end

    # concurrent composition
    def %(f)
      Arrows.concurrent self, Arrows.lift(f)
    end

    # fork composition
    def ^(f)
      Arrows.fork self, f
    end
  end
end
