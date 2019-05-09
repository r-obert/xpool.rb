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
    @job_queue = XChannel.unix Marshal
    @shutdown = false
    @frequency = 0
    @id = fork do
      trap(:SIGUSR1) { @shutdown_requested = true }
      loop &method(:read_loop)
    end
  end

  #
  # Perform a graceful shutdown of the process.
  #
  # @return [void]
  #
  def shutdown
    perform_shutdown 'SIGUSR1' if ! @shutdown
  end

  #
  # Perform a hard shutdown by sending SIGKILL to the process.
  #
  # @return [void]
  #
  def shutdown!
    perform_shutdown 'SIGKILL' if ! @shutdown
  end

  #
  # @return [Integer]
  #   Returns true when the process has shutdown.
  def shutdown?
    @shutdown
  end 

  #
  # @return [Fixnum]
  #   The number of times the process has run a job.
  #
  def frequency
    @frequency
  end

  #
  # @param [#run] job
  #   The job.
  #
  # @param [Object] *args
  #   A variable number of arguments to be passed to #run.
  #
  # @raise [RuntimeError]
  #   Raised when the process has shutdown.
  #
  # @return [XPool::Process]
  #   Returns self.
  #
  def schedule(job,*args)
    if shutdown?
      raise RuntimeError, "The process has shutdown."
    end
    @frequency += 1
    @job_queue.send job: job, args: args
    self
  end

  private
  def perform_shutdown(sig)
    Process.kill sig, @id
    Process.wait @id
  rescue Errno::ECHILD, Errno::ESRCH
  ensure
    @shutdown = true
    @job_queue.close
  end

  def read_loop
    if @job_queue.readable?
      @frequency += 1
      @job_queue.recv[:job].run *msg[:args]
    else
      sleep 0.05
    end
  rescue StandardError
    retry
  ensure
    exit 0 if @shutdown_requested && ! @job_queue.readable?
  end
end
