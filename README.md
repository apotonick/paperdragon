# Paperdragon

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'paperdragon'


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