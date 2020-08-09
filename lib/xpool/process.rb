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
    @run_count = 0
    @id = fork do
      trap(:SIGUSR1) { @shutdown_requested = true }
      loop &method(:read_loop)
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
  #   The number of times a process has run a job.
  #
  def run_count
    @run_count
  end

  #
  # @param [#run] job
  #   The job.
  #
  # @param [Object] *args
  #  Variable number of arguments to be passed to #run.
  #
  # @return [XPool::Process]
  #   Returns self.
  #
  def schedule(job,*args)
    @run_count += 1
    @ch.send job: job, args: args
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
      @run_count += 1
      message = @ch.recv
      message[:job].run *message[:args]
    else
      sleep 0.1
    end
  ensure
    exit 0 if @shutdown_requested && !@ch.readable?
  end
end
