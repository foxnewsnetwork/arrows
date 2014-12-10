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
end