require_relative 'setup'
class XPoolProcessTest < Test::Unit::TestCase
  def setup
    @process = XPool::Process.new
  end

  def teardown
    @process.shutdown!
  end

  def test_frequency
    4.times { @process.schedule Sleeper.new(0.1) }
    assert_equal 4, @process.frequency
  end

  def test_queue
    return "test is pending"
    writers = Array.new(5) { IOWriter.new }
    writers.each { |writer| @process.schedule writer }
    @process.shutdown
    writers.each { |writer| assert writer.wrote_to_disk? }
  end
end
