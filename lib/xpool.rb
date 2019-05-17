class XPool
  require 'xchannel'
  require 'rbconfig'
  require 'timeout'
  require_relative 'xpool/version'
  require_relative 'xpool/process'

  #
  # @param [Integer] size
  #   The number of child processes to spawn.
  #   Defaults to the number of cores on your computers CPU.
  #
  # @return [XPool]
  #
  def initialize(size=number_of_cpu_cores)
    @pool = Array.new(size) { Process.new }
  end

  #
  # @param [Integer] number
  #   The number of child processes to add to the pool.
  #
  # @return
  #   (see XPool#resize!)
  #
  def expand(number)
    resize! size + number
  end

  #
  # @param [Integer] number
  #   The number of child processes to remove from the pool.
  #   A graceful shutdown is performed.
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
  #   The number of child processes to remove from the pool.
  #   A forceful shutdown is performed.
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
  # Broadcasts _job_ to be run across all child processes in the pool.
  #
  # @example
  #   pool = XPool.new 5
  #   pool.broadcast job
  #   pool.shutdown
  #
  # @raise [RuntimeError]
  #   When a subprocess in the pool is dead.
  #
  # @return [Array<XPool::Process>]
  #   Returns an array of XPool::Process objects
  #
  def broadcast(job, *args)
    @pool.map do |process|
      process.schedule job, *args
    end
  end

  #
  # A graceful shutdown of the pool.
  # Each subprocess in the pool empties its queue and exits normally.
  #
  # @param [Integer] timeout
  #   An optional amount of seconds to wait before forcing a shutdown through
  #   {#shutdown!}.
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
  # A forceful shutdown of the pool (through SIGKILL).
  #
  # @return [void]
  #
  def shutdown!
    @pool.each(&:shutdown!)
  end

  #
  # Resize the pool (gracefully, if neccesary)
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
  # Resize the pool (with force, if neccesary).
  #
  # @example
  #   pool = XPool.new 5
  #   pool.resize! 3
  #   pool.shutdown
  #
  # @param [Integer] new_size
  #   The new size of the pool.
  #
  # @return [void]
  #
  def resize!(new_size)
    _resize new_size, true
  end

  #
  # Dispatch a job in a child process.
  #
  # @param
  #   (see Process#schedule)
  #
  # @raise [RuntimeError]
  #   When the pool is dead (no child processes are left running)
  #
  # @return [XPool::Process]
  #   Returns an instance of XPool::Process.
  #
  def schedule(job,*args)
    process = @pool.min_by(&:frequency)
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

  def number_of_cpu_cores
    case RbConfig::CONFIG['host_os']
    when /linux/
      Dir.glob('/sys/devices/system/cpu/cpu[0-9]*').count
    when /darwin|bsd/
      Integer(`sysctl -n hw.ncpu`)
    when /solaris/
      Integer(`kstat -m cpu_info | grep -w core_id | uniq | wc -l`)
    else
      2
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
