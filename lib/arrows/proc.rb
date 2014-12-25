class Arrows::Proc < Proc
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

  # feedback (aka ArrowLoop) composition
  def <=>(g) 
    Arrows.feedback self, g
  end

  # Returns a memoizing version of this proc
  def memoize
    cache = {}
    Arrows.lift -> (args) { cache.has_key?(args) ? cache[args] : (cache[args] = self[args]) }
  end

  # rescues errors from procs
  def rescue_from(error_klass=StandardError, &block)
    Arrows.lift -> (args) {
      begin
        self[args]
      rescue error_klass => e
        yield e, args
      end
    }
  end
end