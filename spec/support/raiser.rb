class Raiser
  def initialize(seconds = 0)
    @seconds = seconds
  end

  def call
    sleep @seconds
    raise RuntimeError, "", %w(42)
  end
end
