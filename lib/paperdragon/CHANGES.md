# 0.0.11

* You can now have any name for attachments in `Model`. This also allows having multiple uploads per model. E.g. the following now works.

    ```ruby
    processable :avatar, Attachment
    processable :image, Attachment
    ```

    You will need `avatar_meta_data` and `image_meta_data` fields, now.

Many thanks to @mrbongiolo for implementing this.

# 0.0.10

* Require Dragonfly 1.0.12 or above and change internal API accordingly. Thanks @acaron for fixing that!

# 0.0.9

* Add `Task#delete!` which allows to delete files in task blocks.

# 0.0.8

* Introduce `Model::Writer` and `Model::Reader` in case you don't like `Model#image`'s fuzzy API.

# 0.0.7

* `Task#process!` (and the delegated `File#process!`) now delete the original version of an attachment if `process!` is used to replace the latter.