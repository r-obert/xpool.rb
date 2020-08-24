class XPool::Process
  #
  # @return [Integer]
  #   The process ID.
  #
  attr_reader :id

  #
  # @return [XPool::Process]
  #   Returns an instance of XPool::Process
  #
  def initialize
    @ch = xchan Marshal
    @shutdown = false
    @call_count = 0
    @id = nil
  end

  def fork
    @id = super do
      trap(:SIGUSR1) { @shutdown_requested = true }
      loop { read_loop }
    end
  end

  #
  # Perform a graceful shutdown of a process.
  #
  # @return [void]
  #
  def shutdown
    perform_shutdown 'SIGUSR1' if !@shutdown
  end

  #
  # Perform a hard shutdown by sending SIGKILL to a process.
  #
  # @return [void]
  #
  def shutdown!
    perform_shutdown 'SIGKILL' if !@shutdown
  end

  #
  # @return [Integer]
  #   Returns true when a process has shutdown.
  #
  def shutdown?
    @shutdown
  end

  #
  # @return [Integer]
  #   The number of times a callable has been scheduled on a process.
  #
  def call_count
    @call_count
  end

  #
  # @param [#call] callable
  #   An object who implements `#call` (except Proc objects).
  #
  # @param [Object] *args
  #  Variable number of arguments to be passed to #call.
  #
  # @return [XPool::Process]
  #   Returns self.
  #
  def schedule(callable, *args)
    @call_count += 1
    @ch.send callable: callable, args: args
    self
  end

  private

  def perform_shutdown(sig)
    Process.kill sig, @id
    Process.wait @id
  rescue Errno::ECHILD, Errno::ESRCH
  ensure
    @shutdown = true
    @ch.close
  end

  def read_loop
    if @ch.readable?
      message = @ch.recv
      message[:callable].call(*message[:args]) rescue nil
    else
      sleep 0.1
    end
  ensure
    exit 0 if @shutdown_requested && !@ch.readable?
  end
end
