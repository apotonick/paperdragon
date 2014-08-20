require 'test_helper'

class PaperdragonModelTest < MiniTest::Spec
  class Avatar
    class Photo < Paperdragon::File
    end

    class Attachment < Paperdragon::Attachment
      self.file_class = Photo
    end

    include Paperdragon::Model
    processable :image, Attachment


    def image_meta_data
      {:thumb => {:uid => "Avatar-thumb"}}
    end
  end

  it { Avatar.new.image[:thumb].url.must_equal "/paperdragon/Avatar-thumb" }


  # minimum setup
  class Image
    include Paperdragon::Model
    processable :image

    def image_meta_data
      {:thumb => {:uid => "Avatar-thumb"}}
    end
  end

  it { Image.new.image[:thumb].url.must_equal "/paperdragon/Avatar-thumb" }
end