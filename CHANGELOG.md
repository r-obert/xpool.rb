# CHANGELOG

## v3.0.0 (unreleased)

* Instead of raising an error, `XPool#shrink` reduces the pool size to 0
  when given a number larger than the pool.

* Remove `XPool#resize!`.

* Remove `XPool#shrink!`.

* Remove `XPool#number_of_cpu_cores`.

* Include `XPool::ObjectMixin` into `Object`.

* Add `XPool::ObjectMixin`.

* Update API docs.

* Stop rescuing `StandardError` and leave it up to the job to handle.

* Rename `XPool::Process#frequency` to `XPool::Process#run_count`
