require "arrows/version"

module Arrows
  class << self
    def fanout(f,g)
      Arrows::Proc.new { |*args| [f[*args], g[*args]] }
    end
    def compose(f,g)
      Arrows::Proc.new { |*args| g[*f[*args]] }
    end
    def fmap(xs, f)
      Arrows::Proc.new { |*args| xs[*args].map { |*x| f[*x] }  }
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
      Arrows::Proc.new { |*args| f[*args] }
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
  end
end
