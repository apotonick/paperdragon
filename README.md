# Paperdragon

_Explicit image processing._

## Summary

Paperdragon gives you image processing as known from [Paperclip](https://github.com/thoughtbot/paperclip), [CarrierWave](https://github.com/carrierwaveuploader/carrierwave) or [Dragonfly](https://github.com/markevans/dragonfly). It allows uploading, cropping, resizing, watermarking, maintaining different versions of an image, and so on.

It provides a very explicit DSL: **No magic is happening behind the scenes, paperdragon makes _you_ implement the processing steps.**

With only a little bit of more code you are fully in control of what gets uploaded where, which image version gets resized when and what gets sent to a background job.

Paperdragon uses the excellent [Dragonfly](https://github.com/markevans/dragonfly) gem for processing, resizing, storing, etc.

Paperdragon is database-agnostic, doesn't know anything about ActiveRecord and _does not_ hook into AR's callbacks.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'paperdragon'
```


## Example

This README only documents the public DSL. You're free to use the public API [documented here](# TODO) if you don't like the DSL.

### Model

Paperdragon has only one requirement for the model: It needs to have a column `image_meta_data`. This is a serialised hash where paperdragon saves UIDs for the different image versions. We'll learn about this in a minute.

```ruby
class User < ActiveRecord::Base # this could be just anything.
  include Paperdragon::Model

  processable :image

  serialize :image_meta_data
end
```

Calling `::processable` advises paperdragon to create a `User#image` reader to the attachment. Nothing else is added to the class.


## Uploading

Processing and storing an uploaded image is an explicit step - you have to code it! This code usually goes to a separate class or an [Operation in Trailblazer](https://github.com/apotonick/trailblazer#domain-layer-operation), don't leave it in the controller if you don't have to.

```ruby
def create
  file = params.delete(:image)

  user = User.create(params) # this is your code.

  # upload code:
  user.image(file) do |v|
    v.process!(:original)                                      # save the unprocessed.
    v.process!(:thumb)   { |job| job.thumb!("75x75#") }        # resizing.
    v.process!(:cropped) { |job| job.thumb!("140x140+20+20") } # cropping.
    v.process!(:public)  { |job| job.watermark! }              # watermark.
  end

  user.save
end
```

This is a completely transparent process.

1. Calling `#image` usually returns the image attachment. However, passing a `file` to it allows to create different versions of the uploaded image in the block.
2. `#process!` requires you to pass in a name for that particular image version. It is a convention to call the unprocessed image `:original`.
3. The `job` object is responsible for creating the final version. This is simply a `Dragonfly::Job` object and gives you [everything that can be done with dragonfly](http://markevans.github.io/dragonfly/imagemagick/).
4. After the block is run, paperdragon pushes a hash with all the images meta data to the model via `model.image_meta_data=`.

For a better understanding and to see how simple it is, go and check out the `image_meta_data` field.

```ruby
 user.image_meta_data #=> {original: {uid: "original-logo.jpg", width: 240, height: 800},
                      #    thumb:    {uid: "thumb-logo.jpg", width: 140, height: 140},
                      #   ..and so on..
                      #   }
 ```


## Rendering Images

After processing, you may want to render those image versions in your app.

```ruby
user.image[:thumb].url
```

This is all you need to retrieve the URL/path for a stored image. Use this for your image tags.

```haml
= img_tag user.image[:thumb].url
```

Internally, Paperdragon will call `model#image_meta_data` and use this hash to find the address of the image.

While gems like paperclip often use several fields of the model to compute UIDs (addresses) at run-time, paperdragon does that once and then dumps it to the database. This completely removes the dependency to the model.


## Reprocessing And Cropping

Once an image has been processed to several versions, you might need to reprocess some of them. As an example, users could re-crop their thumbs.

```ruby
def crop
  user = User.find(params[:id]) # this is your code.

  # reprocessing code:
  cropping = "#{params[:w]}x#{params[:h]}#"

  user.image do |v|
    v.reprocess!(:thumb, Time.now) { |job| job.thumb!(cropping) } # re-crop.
  end

  user.save
end
```

Only a few things have changed compared to the initial processing.

1. We do not pass a file to `#image` anymore. This makes sense as reprocessing will re-use the existing original file.
2. Note that it's not `#process!` but `#reprocess!` indicating a surprising reprocessing.
3. As a second argument to `#reprocess!` a fingerprint string is required. To understand what this does, let's inspect `image_meta_data` once again. (The fingerprint feature is optional but extremely helpful.)


```ruby
 user.image_meta_data #   ..original..
                      #    thumb:    {uid: "thumb-logo-1234567890.jpg", width: 48, height: 48},
                      #   ..and so on..
                      #   }
```

See how the file name has changed? Paperdragon will automatically append the fingerprint you pass into `#reprocess!` to the existing version's file name.


## Renaming

Sometimes you just want to rename files without processing them. For instance, when a new fingerprint for an image is introduced, you want to apply that to all versions.

```ruby
fingerprint = Time.now

user.image do |v|
  v.reprocess!(:thumb, fingerprint) { |job| job.thumb!(cropping) } # re-crop.
  v.rename!(:original, fingerprint) # just rename it.
end
```

This will re-crop the thumb and _rename_ the original.

```ruby
 user.image_meta_data #=> {original: {uid: "original-logo-1234567890.jpg", ..},
                      #    thumb:    {uid: "thumb-logo-1234567890.jpg", ..},
                      #   ..and so on..
                      #   }
 ```


## Deleting

While making images is a wonderful thing, sometimes you need to destroy to create. This is why paperdragon gives you a deleting mechanism, too.

```ruby
user.image do |v|
  v.delete!(:thumb)
end
```

This will also remove the associated metadata from the model.

You can delete all versions of an attachment by omitting the style.

```ruby
user.image do |v|
  v.delete! # deletes :original and :thumb.
end
```


## Replacing Images

It's ok to run `#process!` again on a model with an existing attachment.

```ruby
user.image_meta_data  #=> {original: {uid: "original-logo-1234567890.jpg", ..},
```

Processing here will overwrite the existing attachment.

```ruby
user.image(new_file) do |v|
  v.process!(:original) # overwrites the existing, deletes old.
end
```

```ruby
user.image_meta_data  #=> {original: {uid: "original-new-file01.jpg", ..},
```

While replacing the old with the new upload, the old file also gets deleted.


## Fingerprints

Paperdragon comes with a very simple built-in file naming.

Computing a file UID (or, name, or path) happens in the `Attachment` class. You need to provide your own implementation if you want to change things.

```ruby
class User < ActiveRecord::Base
  include Paperdragon::Model

  class Attachment < Paperdragon::Attachment
    def build_uid(style, file)
      "/path/to/#{style}/#{obfuscator}/#{file.name}"
    end

    def obfuscator
      Obfuscator.call # this is your code.
    end
  end

  processable :image, Attachment # use the class you just wrote.
```

The `Attachment#build_uid` method is invoked when processing images.

```ruby
user.image(file) do |v|
  v.process!(:thumb)   { |job| job.thumb!("75x75#") }
end
```

To create the image UID, _your_ attachment is now being used.

```ruby
 user.image_meta_data #   ..original..
                      #    thumb:    {uid: "/path/to/thumb/ac97dnxid8/logo.jpg", ..},
                      #   ..and so on..
                      #   }
```

What a beautiful, cryptic and mysterious filename you just created!

The same pattern applies for _re-building_ UIDs when reprocessing images.

```ruby
class Attachment < Paperdragon::Attachment
  # def build_uid and the other code from above..

  def rebuild_uid(file, fingerprint)
    file.uid.sub("logo.png", "logo-#{fingerprint}.png")
  end
end
```

This code is used to re-compute UIDs in `#reprocess!`.

That example is stupid, I know, but it shows how you have access to the `Paperdragon::File` instance that represents the existing version of the reprocessed image.


## Local Rails Configuration

Configuration of paperdragon completely relies on [configuring dragonfly](http://markevans.github.io/dragonfly/configuration/). As an example, for a Rails app with a local file storage, I use the following configuration in `config/initializers/paperdragon.rb`.

```ruby
Dragonfly.app.configure do
  plugin :imagemagick

  datastore :file,
    :server_root => 'public',
    :root_path => 'public/images'
end
```

This would result in image UIDs being prefixed accordingly.

```ruby
user.image[:thumb].url #=> "/images/logo-1234567890.png"
```


## S3

As [dragonfly allows S3](https://github.com/markevans/dragonfly-s3_data_store), using the amazon cloud service is straight-forward.

All you need to do is configuring your bucket. The API for paperdragon remains unchanged.

```ruby
require 'dragonfly/s3_data_store'

Dragonfly.app.configure do
  datastore :s3,
    bucket_name: 'my-bucket',
    access_key_id: 'blahblahblah',
    secret_access_key: 'blublublublu'
end
```

Images will be stored "in the cloud" when using `#process!`, renaming, deleting and re-processing do the same!


## Background Processing

The explicit design of paperdragon makes it incredibly simple to move all or certain processing steps to background jobs.

```ruby
class Image::Processor
  include Sidekiq::Worker

  def perform(params)
    user = User.find(params[:id])

    user.image(params[:file]) do |v|
      v.process!(:original)
    end
  end
end
```

Documentation how to use Sidekiq and paperdragon in Traiblazer will be added shortly.

## Validations

Validating uploads are discussed in the _Callbacks_ chapter of the [Trailblazer
book](https://leanpub.com/trailblazer). We use [file_validators](https://github.com/musaffa/file_validators).

## Model: Reader and Writer

If you don't like `Paperdragon::Model#image`'s fuzzy API you can use `Reader` and `Writer`.

The `Writer` will usually be mixed into a form.

```ruby
class AlbumForm < Reform::Form
  extend Paperdragon::Model::Writer
  processable_writer :image
```

This provides the `image!` writer for processing a file.

```ruby
form.image!(file) { |v| v.thumb!("64x64") }
```

Likewise, `Reader` will usually be used in cells or decorators.

```ruby
class AlbumCell < Cell::ViewModel
  extend Paperdragon::Model::Reader
  processable_reader :image
  property :image_meta_data
```

You can now access the `Attachment` via `image`.

```ruby
cell.image[:thumb].url
```


## Paperclip compatibility

I wrote paperdragon as an explicit alternative to paperclip. In the process of doing so, I step-wise replaced upload code, but left the rendering code unchanged. Paperclip has a slightly different API for rendering.

```ruby
user.image.url(:thumb)
```

Allowing your paperdragon-backed model to expose this API is piece-of-cake.

```ruby
class User < ActiveRecord::Base
  include Paperdragon::Paperclip::Model
```

This will allow both APIs for a smooth transition.
