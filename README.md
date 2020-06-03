# xpool.rb

* [Introduction](#introduction)
* [Examples](#examples)
* [Install](#install)
* [License](#license)

## <a id='introduction'>Introduction</a>

xpool.rb is an implementation of a process pool that was built with
[xchan.rb](https://github.com/rg-3/xchan.rb). A process pool can utilize all
cores on a CPU, and provide a separate memory space to run a "job", which could
be any piece of code. Don't confuse xpool.rb with background jobs, it is one of
the many things xpool.rb could be used for.

A process in a pool can be restarted to obtain a clean memory space that could
have been made dirty by code it has ran. A pool can be resized on demand to be 
bigger or smaller.

xpool.rb is best suited for long and short running scripts, it's not well suited
for a Rails application and there are other projects better suited for Rails,
like [Sidekiq](https://github.com/mperham/sidekiq).

## <a id='examples'>Examples</a>

__1.__

The following example defines a class that implements `#run`.
That's the only requirement for a class you'd like to schedule to run on
a pool. The code within the `#run` method will be run on a child process
in the pool that's created by calling `XPool.new(2)`. The argument given
to `.new` is the number of processes a pool should have.
 
 
```ruby
class Worker
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
pool.schedule Worker.new
pool.shutdown
```

__2.__

The `#schedule` method returns an `XPool::Process` object that you can interact
with. It represents the process running scheduled code. Arguments are passed
to the `#run` method from the `#schedule` method.

```ruby
class EmailWorker
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
process = pool.schedule EmailWorker.new, 'user@example.com'
process.id # => Process ID.
pool.shutdown
```

__3.__

The following examples broadcasts the Worker class across the pool,
running it on each child process in the pool:

```ruby
class Worker
  def run
    puts "Hello from #{Process.pid}"
  rescue StandardError
    # It's recommended to manage exceptions yourself.
    # There are no automatic retries.
  end
end
pool = XPool.new(4)
pool.broadcast Worker.new
pool.shutdown
```

__4.__

A pool can be resized to be bigger or smaller:

```ruby
class Worker
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
