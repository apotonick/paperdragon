# 0.0.8

* Introduce `Model::Writer` and `Model::Reader` in case you don't like `Model#image`'s fuzzy API.

# 0.0.7

* `Task#process!` (and the delegated `File#process!`) now delete the original version of an attachment if `process!` is used to replace the latter.