# CHANGELOG

## v3.0.0 (unreleased)

* Remove `XPool#number_of_cpu_cores`.

* Include `XPool::ObjectMixin` into `Object`.

* Add `XPool::ObjectMixin`.

* Update API docs.

* Stop rescuing `StandardError` and leave it up to the job to handle.

* Rename `XPool::Process#frequency` to `XPool::Process#run_count`
