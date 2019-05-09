# xpool.rb

* [Introduction](#introduction)
* [Examples](#examples)
* [SIGUSR1](#SIGUSR1)
* [Install](#install)
* [License](#license)

## <a id='introduction'>Introduction</a>

xpool.rb is a light weight in-memory process pool that was built with [xchannel.rb](https://github.com/r-obert/xchannel.rb).  A process pool can utilise all CPU cores on CRuby, while also providing an isolated memory space for running a job.  

## <a id='examples'>Examples</a>

1.

To schedule a job, define a class that responds to `#run`, then pass an instance
of that class to the `#schedule` method:

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

## <a id='SIGUSR1'>SIGUSR1</a>

Processes in a pool attach a handler for 'SIGUSR1' that shouldn't be over-ridden,
I recommend using SIGUSR2 instead (if that's possible).

## Install

As a rubygem:

    gem install xpool.rb

As a bundled gem, in your Gemfile:

```ruby
gem "xpool.rb", "~> 1.0"
```

## License

This project uses the MIT license, see [LICENSE.txt](./LICENSE.txt) for details.
