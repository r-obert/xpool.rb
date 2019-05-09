class XPool
  require 'xchannel'
  require 'timeout'
  require 'logger'
  require 'rbconfig'
  require_relative "xpool/version"
  require_relative "xpool/process"

  #
  # @param [Fixnum] size
  #   The number of subprocesses to spawn.
  #   Defaults to the number of cores on your CPU.
  #
  # @return [XPool]
  #
  def initialize(size=number_of_cpu_cores)
    @pool = Array.new(size) { Process.new }
  end

  #
  # @param [Fixnum] number
  #   The number of subprocesses to add to the pool.
  #
  # @return
  #   (see XPool#resize!)
  #
  def expand(number)
    resize! size + number
  end

  #
  # @param [Fixnum] number
  #   The number of subprocesses to remove from the pool.
  #   A graceful shutdown is performed.
  #
  # @raise
  #   (see XPool#shrink!)
  #
  # @return
  #   (see Xpool#shrink!)
  #
  def shrink(number)
    present_size = size
    raise_if number > present_size,
      ArgumentError,
      "cannot shrink pool by #{number}. pool is only #{present_size} in size."
    resize present_size - number
  end

  #
  # @param [Fixnum] number
  #   The number of subprocesses to remove from the pool.
  #   A forceful shutdown is performed.
  #
  # @raise [ArgumentError]
  #   When _number_ is greater than {#size}.
  #
  # @return
  #   (see XPool#resize!)
  #
  def shrink!(number)
    present_size = size
    raise_if number > present_size,
      ArgumentError,
      "cannot shrink pool by #{number}. pool is only #{present_size} in size."
    resize! present_size - number
  end

  #
  # Broadcasts _unit_ to be run across all subprocesses in the pool.
  #
  # @example
  #   pool = XPool.new 5
  #   pool.broadcast unit
  #   pool.shutdown
  #
  # @raise [RuntimeError]
  #   When a subprocess in the pool is dead.
  #
  # @return [Array<XPool::Process>]
  #   Returns an array of XPool::Process objects
  #
  def broadcast(unit, *args)
    @pool.map do |process|
      process.schedule unit, *args
    end
  end

  #
  # A graceful shutdown of the pool.
  # Each subprocess in the pool empties its queue and exits normally.
  #
  # @param [Fixnum] timeout
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
        XPool.log "'#{timeout}' seconds elapsed, switching to hard shutdown."
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
  # @param [Fixnum] new_size
  #   The new size of the pool.
  #
  # @return [void]
  #
  def resize!(new_size)
    _resize new_size, true
  end

  #
  # Dispatch a unit of work in a subprocess.
  #
  # @param
  #   (see Process#schedule)
  #
  # @raise [RuntimeError]
  #   When the pool is dead (no subprocesses are left running)
  #
  # @return [XPool::Process]
  #   Returns an instance of XPool::Process.
  #
  def schedule(unit,*args)
    if size == 0 # dead pool
      raise RuntimeError,
        "cannot schedule unit of work on a dead pool"
    end
    process = @pool.reject(&:dead?).min_by { |p| p.frequency }
    process.schedule unit, *args
  end

  #
  # @return [Fixnum]
  #   Returns the number of alive subprocesses in the pool.
  #
  def size
    @pool.count(&:alive?)
  end

  #
  # @return [Boolean]
  #   Returns true when all subprocesses in the pool are busy.
  #
  def dry?
    @pool.all?(&:busy?)
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
