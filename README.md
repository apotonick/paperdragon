# Paperdragon

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'paperdragon'



Paperclip Compatibility

1. Stores file to same location as paperclip would do.
2. `Photo#url` will return the same URL as paperclip.

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