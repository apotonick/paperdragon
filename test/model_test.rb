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
  class Image < OpenStruct
    include Paperdragon::Model
    processable :image
  end

  it { Image.new(:image_meta_data => {:thumb => {:uid => "Avatar-thumb"}}).image[:thumb].url.must_equal "/paperdragon/Avatar-thumb" }


  # process with #image{}
  let (:logo) { Pathname("test/fixtures/apotomo.png") }

  it do
    model = Image.new
    model.image(logo) do |v|
      v.process!(:original)
      v.process!(:thumb) { |j| j.thumb!("16x16") }
    end

    model.image_meta_data.must_equal({:original=>{:width=>216, :height=>63, :uid=>"original-apotomo.png"}, :thumb=>{:width=>16, :height=>5, :uid=>"thumb-apotomo.png"}})
  end
end