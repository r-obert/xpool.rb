# CHANGELOG

## HEAD

* Nothing yet.

## v3.0.0

* Rename `{XPool, XPool::Process}#run_count` to `call_count`.

* Add `XPool::Process#fork`.

* Rescue and swallow errors left unhandled by `#call`.

* Invoke `#call` method instead of `#run`.

* Refer to items you can schedule as "callable" instead of as "job".

* `XPool#shrink` reduces the pool size to 0 when given a number larger than the
  pool, instead of raising an error.

* Remove `XPool#resize!`.

* Remove `XPool#shrink!`.

* Remove `XPool#number_of_cpu_cores`.

* Include `XPool::ObjectMixin` into `Object`.

* Add `XPool::ObjectMixin`.

* Update API docs.

* Stop rescuing `StandardError` and leave it up to the job to handle.

* Rename `XPool::Process#frequency` to `XPool::Process#run_count`
