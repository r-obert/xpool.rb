# xpool.rb

* [Introduction](#introduction)
* [Examples](#examples)
* [Install](#install)
* [License](#license)

## <a id='introduction'>Introduction</a>

xpool.rb is an implementation of a process pool that was built with
[xchan.rb](https://github.com/rg-3/xchan.rb). A process pool can utilize all
cores on a CPU, and also provide an isolated memory space to run a job / other
code.

xpool.rb is best suited for long and short running scripts, it's not well suited
for a Rails application and there are other projects better suited for Rails,
like [Sidekiq](https://github.com/mperham/sidekiq).

## <a id='examples'>Examples</a>

__1.__

To schedule a job, define a class that responds to `#run`, then pass an instance
of that class to the `#schedule` method. The first argument given to `XPool.new` is
the number of processes to populate a pool with. It defaults to the number of cores
available on your computers CPU.

```ruby
# Define a job before initializing the pool or you will run into confusing
# serialization errors.
class Job
  def run
    do_work
  rescue StandardError
    # It's recommended to rescue exceptions inside a job.
    # If an exception is not rescued, the job won't be retried.
  end

  private
  def do_work
    # ...
  end
end
pool = XPool.new(2)
pool.schedule(Job.new)
pool.shutdown
```

__2.__

The `#schedule` method returns an `XPool::Process` object that you can interact
with. It represents the process running a job. Arguments can be passed to a job
from the `#schedule` method.

```ruby
class Job
  def run(email)
    deliver_email(email)
  rescue StandardError
    # It's recommended to rescue exceptions inside a job.
    # If an exception is not rescued, the job won't be retried.
  end

  private
  def deliver_email(email)
    # ..
  end
end
pool = XPool.new(2)
process = pool.schedule(Job.new, 'user@example.com')
process.id # => Process ID.
pool.shutdown
```

__3.__

Broadcast a job to run on all processes in a pool:

```ruby
class Job
  def run
    puts "Hello from #{Process.pid}"
  rescue StandardError
    # It's recommended to rescue exceptions inside a job.
    # If an exception is not rescued, the job won't be retried.
  end
end
pool = XPool.new(4)
pool.broadcast(Job.new)
pool.shutdown
```

__4.__

A pool can be resized to be bigger or smaller.

```ruby
class Job
  def run
    do_work
  rescue StandardError
    # It's recommended to rescue exceptions inside a job.
    # If an exception is not rescued, the job won't be retried.
  end

  private
  def do_work
    # ...
  end
end
pool = XPool.new(4)
pool.shrink! 2 # Reduces the number of pool processes to 2.
pool.expand! 3 # Increase the number of pool processes to 5.
pool.shutdown
```

## <a id="install">Install</a>

Rubygems:

    gem install xpool.rb

Gemfile:

```ruby
gem "xpool.rb", "~> 2.0"
```

## <a id="license">License</a>

This project uses the MIT license, see [LICENSE.txt](./LICENSE.txt) for details.
