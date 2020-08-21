# xpool.rb

**Table of contents**

* [Introduction](#introduction)
* [Examples](#examples)
* [Install](#install)
* [License](#license)

## <a id='introduction'>Introduction</a>

xpool.rb is an implementation of a process pool that was built with
[xchan.rb](https://github.com/rg-3/xchan.rb). A process pool can utilize all
cores on a CPU, and each process in a pool provides a separate memory space to
run a "callable", which is any object that implements a `call` method
(except Proc objects).

xpool.rb is intended for short and long running scripts and possibly small web
applications. I recommend [Sidekiq](https://github.com/mperham/sidekiq) for
a solution Rails applications can use.

## <a id='examples'>Examples</a>

**#1**

Any object that implements `#call` can be scheduled, excluding `Proc` objects.

Although there are no automatic retries, error handling is transparent and
automatic retries easily implemented. It is recommended to _always_ rescue and
handle errors in some way. The example handles errors through a retry.

If errors are left unrescued, xpool.rb rescues them and the process
then picks up the next item on its queue.

```ruby
class EmailDelivery
  def initialize(email)
    @email = email
  end

  def call(attempts = 3)
    deliver_email(@email)
  rescue StandardError => ex
    attempts -= 1
    attempts.zero? ? Airbrake.notify(ex) : retry
  end

  private

  def deliver_email(email)
  end
end
pool = xpool(size: 2)
pool.schedule EmailDelivery.new('user@example.com')
pool.shutdown
```

**#2**

The first example shows just one approach for running something on a pool. You
could also take another approach using a module function that is passed arguments
via `pool.schedule`.


```ruby
module EmailDelivery
  def self.call(email, attempts = 3)
    # code to deliver email
  rescue StandardError
    attempts -= 1
    attempts.zero? ? Airbrake.notify(ex) : retry
  end
end
pool = xpool(size: 2)
pool.schedule EmailDelivery, 'user@example.com'
pool.shutdown
```

## <a id="install">Install</a>

The easiest way to install xpool.rb is via RubyGems:

    gem install xpool.rb

## <a id="license">License</a>

The MIT license, see [LICENSE.txt](./LICENSE.txt) for details.
