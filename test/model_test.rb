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

  # model has image_meta_data hash.
  it { Avatar.new.image[:thumb].url.must_equal "/paperdragon/Avatar-thumb" }
  # model doesn't have upload, yet. returns empty attachment.
  it { Image.new.image.metadata.must_equal({}) }


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


    model.image do |v|
      v.reprocess!(:thumb, "1") { |j| j.thumb!("8x8") }
    end

    model.image_meta_data.class.must_equal Hash
    model.image_meta_data.must_equal({:original=>{:width=>216, :height=>63, :uid=>"original-apotomo.png"}, :thumb=>{:width=>8, :height=>2, :uid=>"thumb-apotomo-1.png"}})
  end


  # passing options from image(file, {..}) to the Attachment.
  class ImageWithAttachment < OpenStruct
    include Paperdragon::Model

    class Attachment < Paperdragon::Attachment
      def build_uid(style, file)
        @options.inspect # we use options here!
      end

      def rebuild_uid(style, file)
        @options.inspect
      end
    end

    processable :image, Attachment
  end

  it do
    model = ImageWithAttachment.new
    model.image(logo, :path => "/") do |v|
      v.process!(:original)
    end

    # this assures that both :model and :path (see above) are passed through.
    model.image_meta_data.must_equal({:original=>{:width=>216, :height=>63, :uid=>"{:path=>\"/\", :model=>_<PaperdragonModelTest::ImageWithAttachment>}"}})

    model.image(nil, :new => true) do |v|
      v.reprocess!(:original, "1") { |j| j.thumb!("8x8") }
    end

    model.image_meta_data.must_equal({:original=>{:width=>8, :height=>2, :uid=>"{:new=>true, :model=>#<PaperdragonModelTest::ImageWithAttachment image_meta_data={:original=>{:width=>216, :height=>63, :uid=>\"{:path=>\\\"/\\\", :model=>_<PaperdragonModelTest::ImageWithAttachment>}\"}}>}"}})
  end
end