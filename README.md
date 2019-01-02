# ZPool

## <a id='introduction'>Introduction</a>

zpool is a lightweight process pool. A pool manages a group of subprocesses
that are used when it is asked to dispatch a 'unit of work'. A 'unit of work'
is defined as any object that implements the `run` method.

In order to send a 'unit of work' between processes each subprocess has its own
'message queue' that the pool writes to when it has been asked to schedule a
unit of work. A unit of work is serialized(on write to queue), and
deserialized(on read from queue). The serializer used under the hood is called
[Marshal](http://rubydoc.info/stdlib/core/Marshal) and might be familiar to
you already.

The logic for scheduling a unit of work is straightforward. A pool asks each
and every subprocess under its control how frequently its message queue has
been written to. The subprocess with the queue that has the least writes is told
to schedule the next unit of work. In practical terms this means if you have a
pool with five subprocesses and schedule a unit of work five times, each
subprocess in the pool would have executed the unit of work once.

A pool can become "dry" whenever all its subprocesses are busy. If you schedule
a unit of work on a dry pool the same scheduling logic applies but instead of
the unit of work executing right away it will be executed whenever the
assigned subprocess is no longer busy. It is also possible to query the pool
and ask if it is dry, but you can also ask an individual subprocess if it is
busy.

By default zpool will create a pool with X subprocesses, where X is the number
of cores on your CPU. This seems like a reasonable default, but if you should
decide to choose otherwise you can set the size of the pool when it is
initialized. The pool can also be resized at runtime if you decide you need
to scale up or down.

A unit of work may fail whenever an exception is left unhandled. When this
happens zpool rescues the exception, marks the process as "failed", and
re-raises the exception so that the failure can be seen. Finally, the process
running the unit of work exits, and pool is down one process. A failed process
can be restarted and interacted with, though, so it is possible to recover.

## <a id='examples'>Examples</a>

1.

Schedule a unit of work:

```ruby
#
# Make sure you define your units of work before
# you create a process pool or you'll get strange
# serialization errors.
#
class Unit
  def run
    sleep 1
  end
end
pool = ZPool.new 2
pool.schedule Unit.new
pool.shutdown
```

2.

The `ZPool::Process` object assigned to run a unit of work is returned from the  
`#schedule` method:

```ruby
class Unit
  def run
    sleep 1
  end
end
pool = ZPool.new 2
subprocess = pool.schedule Unit.new
p subprocess.busy? # => true
pool.shutdown
```

3.

Schedule a unit of work to run across all available processes in a pool:

```ruby
class Unit
  def run
    puts Process.pid
  end
end
pool = ZPool.new 4
pool.broadcast Unit.new
pool.shutdown
```

## SIGUSR1

All zpool managed subprocesses define a signal handler for the SIGUSR1 signal.
A unit of work should never define a signal handler for SIGUSR1 because that
would overwrite the handler defined by zpool. SIGUSR2 is not caught by zpool
and it could be a good second option.


## Install

    $ gem install zpool.rb

## License

This project uses the MIT license, see [LICENSE.txt](./LICENSE.txt) for details.
