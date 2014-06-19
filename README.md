# Paperdragon

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'paperdragon'



Paperclip Compatibility

Paperclip uses several columns to compute the UID. Once this is done, it doesn't store that UID in the database but updates the respective fields, which makes it a bit awkward to maintain.

Paperdragon simply dumps the image uid along with meta data into image_meta_data.

You have to take care of updating image_fingerprint etc yourself when changing stuff and still using paperclip to compute urls.