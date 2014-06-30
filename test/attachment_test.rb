require 'test_helper'

class AttachmentSpec < MiniTest::Spec
  class Attachment < Paperdragon::Attachment
    class File < Paperdragon::File
    end
    self.file_class= File

  private
    def uid_from(style, metadata)
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