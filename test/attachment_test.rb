require 'test_helper'

class AttachmentSpec < MiniTest::Spec
  class Attachment < Paperdragon::Attachment
    class File < Paperdragon::File
    end
    self.file_class= File

  private
    def uid_from(style)
      "/uid/#{style}"
    end
  end

  describe "existing" do
    subject { Attachment.new({:original => {:uid=>"/uid/1234.jpg"}}) }

    it { subject[:original].must_be_kind_of AttachmentSpec::Attachment::File }
    it { subject[:original].uid.must_equal "/uid/1234.jpg" }
  end

  describe "new" do
    subject { Attachment.new(nil) }

    it { subject[:original].must_be_kind_of AttachmentSpec::Attachment::File }
    it { subject[:original].uid.must_equal "/uid/original" }
  end
end


class AttachmentModelSpec < MiniTest::Spec
  class Attachment < Paperdragon::Attachment
    include Paperdragon::Attachment::Model

    class File < Paperdragon::File
    end
    self.file_class= File

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