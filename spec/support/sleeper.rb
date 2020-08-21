class Sleeper
  def initialize(seconds)
    @seconds = seconds
  end

  def call
    sleep @seconds
  end
end
