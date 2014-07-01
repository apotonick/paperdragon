require 'test_helper'

require 'paperdragon/model'
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
end