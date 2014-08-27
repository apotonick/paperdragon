# Paperdragon

_Explicit image processing._

## Summary

Paperdragon gives you image processing as known from Paperclip, CarrierWave or [Dragonfly](https://github.com/markevans/dragonfly). It allows uploading, cropping, resizing, watermarking, maintaining different versions of an image, and so on.

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
                      #    thumb:    {uid: "thumb-logo.jpg", width: 48, height: 48},
                      #   ..and so on..
                      #   }
 ```


## Rendering Images

After processing, you may want to render those image versions in your app.

```ruby
user.image[:thumb].url
```

This is all you need to retrieve the URL/path for a stored image.

Internally, Paperdragon will call `model#image_meta_data` and use this hash to find the address of the image.

While gems like paperclip often use several fields of the model to compute UIDs (addresses) at run-time, paperdragon does that once and then dumps it to the database. This completely removes the dependency to the model.


## Reprocessing And Cropping



Fingerprints
Configuration
S3
Background Processing



Paperdragon is completely decoupled from ActiveRecord. Attachment-related calls are delegated to paperdragon objects, the model is solely used for persisting file UIDs.

Where Paperclip or Carrierwave offer you a handy DSL to configure the processing, Paperdragon comes with an API. You _program_ what you wanna do. This is only a tiny little bit more code and gives you complete control over the entire task.



The goal is to make you _understand_ what is going on.

* you control processing and storage, e.g. first thumbnails and cropping, then process the rest. easy to sidekiq.
error handling
UID generation handled by you. also, updating (e.g. new fingerprint)
* only process subset, e.g. in test.


File

All process methods return Metadata hash
yield Job, save it from the block if you need it
override #default_metadata_for when you wanna change it
last arg in process method gets merged into metadata hash

Design
Operations in File look like scripts per design. I could have abstracted various steps into higher level methods, however, as file processing _is_ a lot scripting, I decided to sacrifice redundancy for better understandable code.


Paperclip Compatibility

1. Stores file to same location as paperclip would do.
2. `Photo#url` will return the same URL as paperclip.
3. P::Model image.url(:thumb) still works, your rendering code will still work.
4. Cleaner API for generating URLs. For example, we needed to copy images from production to staging. With paperclip, it was impossible to create paths for both environments.

Paperclip uses several columns to compute the UID. Once this is done, it doesn't store that UID in the database but updates the respective fields, which makes it a bit awkward to maintain.

Paperdragon simply dumps the image uid along with meta data into image_meta_data.

You have to take care of updating image_fingerprint etc yourself when changing stuff and still using paperclip to compute urls.




Original paperclip UID:
it { pic.image(:original).should == "/system/test/pics/images/002/216/376/bc7b26d983db8ced792e38f0c34aba417f75c2e7_key/original-c5b7e624adc5b67e13435baf26e65bc8-1399980114/DSC_4876.jpg" }

1) Uid
     Failure/Error: should == "system/test/pics/images/002/216/376/bc7b26d983db8ced792e38f0c34aba417f75c2e7_key/original-c5b7e624adc5b67e13435baf26e65bc8-1399980114/DSC_4876.jpg" }
       expected: "system/test/pics/images/002/216/376/bc7b26d983db8ced792e38f0c34aba417f75c2e7_key/original-c5b7e624adc5b67e13435baf26e65bc8-1399980114/DSC_4876.jpg"
            got: "system/test/pics/images/002/216/376/bc7b26d983db8ced792e38f0c34aba417f75c2e7_key/original/DSC_4876.jpg" (using ==)

Feel like a hacker reverse-engineering

## Rails

Dragonfly.app.configure do
  plugin :imagemagick

  datastore :file,
    :server_root => 'public',
    :root_path => 'public/images'
end