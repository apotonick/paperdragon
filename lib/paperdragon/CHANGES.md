# 0.0.10

* Require Dragonfly 1.0.12 or above and change internal API accordingly. Thanks @acaron for fixing that!

# 0.0.9

* Add `Task#delete!` which allows to delete files in task blocks.

# 0.0.8

* Introduce `Model::Writer` and `Model::Reader` in case you don't like `Model#image`'s fuzzy API.

# 0.0.7

* `Task#process!` (and the delegated `File#process!`) now delete the original version of an attachment if `process!` is used to replace the latter.