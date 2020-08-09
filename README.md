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

**#1**

This example demonstrates scheduling the `Job` class, any class that implements 
a `#run` method can be scheduled. It is recommended to rescue exceptions yourself
because there's no auto retries, error handling is left up to you. The `xpool` 
method is inherited by `Object` and it returns an instance of `XPool`. 

```ruby
class Job
  def run
    cpu_intesive_work
  rescue StandardError
    # Handle error
  end

  private

  def cpu_intesive_work
  end
end
pool = xpool(size: 2)
pool.schedule Job.new
pool.shutdown
```

## <a id="install">Install</a>

The easiest way to install xpool.rb is via RubyGems:

    gem install xpool.rb

## <a id="license">License</a>

The MIT license, see [LICENSE.txt](./LICENSE.txt) for details.
