class Sleeper
  def initialize(seconds)
    @seconds = seconds
  end

  def run
    sleep @seconds
  end
end
