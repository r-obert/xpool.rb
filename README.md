# xpool.rb

**Table of contents**

* [Introduction](#introduction)
* [Examples](#examples)
* [Install](#install)
* [License](#license)

## <a id='introduction'>Introduction</a>

xpool.rb is an implementation of a process pool that was built with
[xchan.rb](https://github.com/rg-3/xchan.rb). A process pool can utilize all
cores on a CPU, and provide a separate memory space to run a "job", which could
be any piece of code.

xpool.rb is best suited for long and short running scripts. If you're looking
for a Rails solution for background jobs I suggest checking out a project
like [Sidekiq](https://github.com/mperham/sidekiq).

## <a id='examples'>Examples</a>

__1.__

The following example defines a class that implements `#run`.  
That's the only requirement for a class you'd like to schedule.  
The `#run` method will be called from a child process in the pool.


```ruby
class Job
  def run
    do_work
  rescue StandardError
    # It's recommended to manage exceptions yourself.
    # There are no automatic retries.
  end

  private

  def do_work
    # ...
  end
end
pool = XPool.new(2)
pool.schedule Job.new
pool.shutdown
```

__2.__

The `#schedule` method returns an instance of `XPool::Process` that you can interact with.  
Arguments are forwarded to the `#run` method from the `#schedule` method.

```ruby
class EmailJob
  def run(email)
    deliver_email(email)
  rescue StandardError
    # It's recommend to manage exceptions yourself.
    # There are no automatic retries.
  end

  private

  def deliver_email(email)
    # ..
  end
end
pool = XPool.new(2)
process = pool.schedule EmailJob.new, 'user@example.com'
process.id # => Process ID.
pool.shutdown
```

__3.__

The following example broadcasts the Job class across the pool,
running it on each child process in the pool:

```ruby
class Job
  def run
    puts "Hello from #{Process.pid}"
  rescue StandardError
    # It's recommended to manage exceptions yourself.
    # There are no automatic retries.
  end
end
pool = XPool.new(4)
pool.broadcast Job.new
pool.shutdown
```

__4.__

A pool can be resized to be bigger or smaller:

```ruby
class Job
  def run
    do_work
  rescue StandardError
    # It's recommended to manage exceptions yourself.
    # There are no automatic retries.
  end

  private

  def do_work
    # ...
  end
end
pool = XPool.new(4)
pool.shrink!(2) # Reduces the number of pool processes to 2.
pool.expand!(3) # Expands the number of pool processes to 5.
pool.shutdown
```

## <a id="install">Install</a>

    gem install xpool.rb

## <a id="license">License</a>

This project uses the MIT license, see [LICENSE.txt](./LICENSE.txt) for details.
