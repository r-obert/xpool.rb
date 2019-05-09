# xpool.rb

* [Introduction](#introduction)
* [Examples](#examples)
* [The SIGUSR1 signal](#SIGUSR1)
* [Install](#install)
* [License](#license)

## <a id='introduction'>Introduction</a>

xpool.rb is a light weight in-memory process pool that was built with [xchannel.rb](https://github.com/r-obert/xchannel.rb).  A process pool can utilise all CPU cores on CRuby, while also providing an isolated memory space for running a job.  

## <a id='examples'>Examples</a>

1.

To schedule a job, define a class that responds to `#run`, then pass an instance
of that class to the `#schedule` method. The first argument given to `XPool.new` is 
the number of processes to populate a pool with. It defaults to the number of cores 
available on your computers CPU.

```ruby
# *Important*
# Be sure to define a job before initialising the pool or you could run into
# confusing serialisation errors.
class Job
  def run
    sleep 1
  end
end
pool = XPool.new(2)
pool.schedule(Job.new)
pool.shutdown
```

2.

The `#schedule` method returns an `XPool::Process` object that you can interact
with. It represents the process chosen to run a job.

```ruby
class Job
  def run
    sleep 1
  end
end
pool = XPool.new(2)
process = pool.schedule(Job.new)
process.busy? # => true
pool.shutdown
```

3.

Broadcast a job to run on all processes in a pool:

```ruby
class Job
  def run
    puts Process.pid
  end
end
pool = XPool.new(4)
pool.broadcast Job.new
pool.shutdown
```

## <a id='SIGUSR1'>The SIGUSR1 signal</a>

SIGUSR1 is reserved for use by xpool.rb, it is caught when shutting down a process.
Feel free to use `SIGUSR2` instead.

## <a id="install">Install</a>

As a rubygem:

    gem install xpool.rb

As a bundled gem, in your Gemfile:

```ruby
gem "xpool.rb", "~> 1.0"
```

## <a id="license">License</a>

This project uses the MIT license, see [LICENSE.txt](./LICENSE.txt) for details.
