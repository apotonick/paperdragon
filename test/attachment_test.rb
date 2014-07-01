require 'test_helper'

class AttachmentSpec < MiniTest::Spec
  class Attachment < Paperdragon::Attachment
  private
    def uid_from(style)
      "/uid/#{style}"
    end
  end

  describe "existing" do
    subject { Attachment.new({:original => {:uid=>"/uid/1234.jpg"}}) }

    # it { subject[:original].must_be_kind_of Paperdragon::File }
    it { subject[:original].uid.must_equal "/uid/1234.jpg" }
    it { subject[:original].options.must_equal({:uid=>"/uid/1234.jpg"}) }
  end

  describe "new" do
    subject { Attachment.new(nil) }

    # it { subject[:original].must_be_kind_of Paperdragon::File }
    it { subject[:original].uid.must_equal "/uid/original" }
    it { subject[:original].options.must_equal({}) }
  end


  class OverridingAttachment < Paperdragon::Attachment
    class File < Paperdragon::File
      def uid
        "from/file"
      end
    end
    self.file_class= File
  end

  it { OverridingAttachment.new(nil)[:original].uid.must_equal "from/file" }
end


class AttachmentModelSpec < MiniTest::Spec
  class Attachment < Paperdragon::Attachment
    include Paperdragon::Attachment::Model # model.image_meta_data
  private
    def uid_from(model, style)
      "#{model.class}/uid/#{style}"
    end
  end

  describe "existing" do
    subject { Attachment.new(OpenStruct.new(:image_meta_data => {:original => {:uid=>"/uid/1234.jpg"}})) }

    it { subject[:original].uid.must_equal "/uid/1234.jpg" }
  end

  describe "new" do
    subject { Attachment.new(OpenStruct.new) }

    it { subject[:original].uid.must_equal "OpenStruct/uid/original" }
  end
end