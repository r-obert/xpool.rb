require_relative 'setup'

class XPoolTest < Test::Unit::TestCase
  POOL_SIZE = 2

  def setup
    @pool = XPool.new POOL_SIZE
  end

  def teardown
    mocha_teardown
    @pool.shutdown!
  end

  def test_broadcast
    subprocesses = @pool.broadcast Sleeper.new(1)
    subprocesses.each { |subprocess| assert_equal 1, subprocess.frequency }
  end

  def test_size
    assert_equal POOL_SIZE, @pool.size
  end

  def test_queue
    @pool.resize!(1)
    writers = Array.new(POOL_SIZE) { IOWriter.new }
    writers.each { |writer| @pool.schedule writer }
    @pool.shutdown
    writers.each { |writer| assert writer.wrote_to_disk? }
  end

  def test_distribution_of_work
    subprocesses = Array.new(POOL_SIZE) { @pool.schedule Sleeper.new(0.1) }
    subprocesses.each { |subprocess| assert_equal 1, subprocess.frequency }
  end

  def test_resize!
    @pool.resize! 1
    assert_equal 1, @pool.instance_variable_get(:@pool).size
  end

  def test_expand
    @pool.expand 1
    assert_equal POOL_SIZE + 1, @pool.size
  end

  def test_shrink
    XPool::Process.any_instance.expects(:shutdown).once
    @pool.shrink 1
    assert_equal POOL_SIZE - 1, @pool.size
  end

  def test_shrink!
    XPool::Process.any_instance.expects(:shutdown!).once
    @pool.shrink! 1
    assert_equal POOL_SIZE - 1, @pool.size
  end

  def test_shrink_with_excess_number
    assert_raises ArgumentError do
      @pool.shrink! POOL_SIZE + 1
    end
  end
end
