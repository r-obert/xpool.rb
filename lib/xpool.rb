class XPool
  require 'xchan'
  require 'rbconfig'
  require 'timeout'
  require_relative 'xpool/version'
  require_relative 'xpool/process'

  module ObjectMixin
    def xpool(size: )
      XPool.new(size: size)
    end
  end

  class ::Object
    include ObjectMixin
  end

  #
  # @param [Integer] size
  #  The number of child processes to spawn.
  #
  # @return [XPool]
  #
  def initialize(size: )
    @pool = Array.new(size) { Process.new }
  end

  #
  # @param [Integer] number
  #  The number of child processes to add to a pool.
  #
  # @return
  #   (see XPool#resize!)
  #
  def expand(number)
    resize! size + number
  end

  #
  # @param [Integer] number
  #  The number of child processes to remove from a pool.
  #
  # @raise
  #   (see XPool#shrink!)
  #
  # @return
  #   (see Xpool#shrink!)
  #
  def shrink(number)
    raise_if number > size,
      ArgumentError,
      "cannot shrink pool by #{number}. pool is only #{size} in size."
    resize size - number
  end

  #
  # @param [Integer] number
  #   The number of child processes to remove from a pool.
  #
  # @raise [ArgumentError]
  #   When _number_ is greater than {#size}.
  #
  # @return
  #   (see XPool#resize!)
  #
  def shrink!(number)
    raise_if number > size,
      ArgumentError,
      "cannot shrink pool by #{number}. pool is only #{size} in size."
    resize! size - number
  end

  #
  # Broadcasts *job* to run on all child processes in a pool.
  #
  # @example
  #   pool = XPool.new 5
  #   pool.broadcast job
  #   pool.shutdown
  #
  # @return [Array<XPool::Process>]
  #   Returns an array of {XPool::Process} objects.
  #
  def broadcast(job, *args)
    @pool.map {|process| process.schedule job, *args}
  end

  #
  # Performs a graceful shutdown of a pool.
  #
  # @param [Integer] timeout
  #   An optional amount of seconds to wait before forcing a 
  #   shutdown through `SIGKILL`.
  #
  # @return [void]
  #
  def shutdown(timeout=nil)
    if timeout
      begin
        Timeout.timeout(timeout) do
          @pool.each(&:shutdown)
        end
      rescue Timeout::Error
        shutdown!
      end
    else
      @pool.each(&:shutdown)
    end
  end

  #
  # Resize a pool gracefully.
  #
  # @param
  #   (see XPool#resize!)
  #
  # @return [void]
  #
  def resize(new_size)
    _resize new_size, false
  end

  #
  # Resize a pool with force.
  #
  # @example
  #   pool = XPool.new 5
  #   pool.resize! 3
  #   pool.shutdown
  #
  # @param [Integer] new_size
  #   The new size of a pool.
  #
  # @return [void]
  #
  def resize!(new_size)
    _resize new_size, true
  end

  #
  # Dispatch a job to a child process.
  #
  # @param
  #   (see Process#schedule)
  #
  # @return [XPool::Process]
  #
  def schedule(job,*args)
    process = @pool.min_by(&:run_count)
    process.schedule job, *args
  end

  #
  # @return [Integer]
  #   Returns the number of child processes in a pool.
  #
  def size
    @pool.size
  end

  private

  def raise_if(predicate, e, m)
    if predicate
      raise e, m
    end
  end

  def _resize(new_size, with_force)
    new_size -= 1
    old_size = size - 1
    if new_size == old_size
      # do nothing
    elsif new_size < old_size
      meth = with_force ? :shutdown! : :shutdown
      @pool[new_size+1..old_size].each(&meth)
      @pool = @pool[0..new_size]
    else
      @pool += Array.new(new_size - old_size) { Process.new }
    end
  end
end
