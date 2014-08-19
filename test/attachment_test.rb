require 'test_helper'

class AttachmentSpec < MiniTest::Spec
  class Attachment < Paperdragon::Attachment
  private
    def uid_from(style)
      "/uid/#{style}"
    end
  end

  describe "existing" do
    subject { Attachment.new({:original => {:uid=>"/uid/1234.jpg", :width => 99}}) }

    it { subject[:original].uid.must_equal "/uid/1234.jpg" }
    it { subject[:original].options.must_equal({:uid=>"/uid/1234.jpg", :width => 99}) }
    it { subject.exists?.must_equal true }
  end

  describe "new" do
    subject { Attachment.new(nil) }

    it { subject[:original].uid.must_equal "/uid/original" }
    it { subject[:original].options.must_equal({}) }
    it { subject.exists?.must_equal false }
  end

  describe "new with empty metadata hash" do
    subject { Attachment.new({}) }

    it { subject[:original].uid.must_equal "/uid/original" }
    it { subject[:original].options.must_equal({}) }
    it { subject.exists?.must_equal false }
  end


  # test passing options into Attachment and use that in #build_uid.
  class AttachmentUsingOptions < Paperdragon::Attachment
  private
    def build_uid(style, file)
      "uid/#{style}/#{options[:filename]}"
    end
  end

  # use in new --> build_uid.
  it { AttachmentUsingOptions.new(nil, {:filename => "apotomo.png"})[:original].uid.must_equal "uid/original/apotomo.png" }


  # test using custom File class in Attachment.
  class OverridingAttachment < Paperdragon::Attachment
    class File < Paperdragon::File
      def uid
        "from/file"
      end
    end
    self.file_class= File
  end

  it { OverridingAttachment.new(nil)[:original, Pathname.new("not-considered.JPEG")].uid.must_equal "from/file" }


  # test UID sanitising. this happens only when computing the UID with a new attachment!
  describe "insane filename" do
    it { AttachmentUsingOptions.new(nil, {:filename => "(use)? apotomo #1#.png"})[:original].uid.must_equal "uid/original/(use)_ apotomo _1_.png" }
  end
end


class AttachmentModelSpec < MiniTest::Spec
  class Attachment < Paperdragon::Attachment
  private
    def build_uid(style, file)
      "#{options[:model].class}/uid/#{style}/#{options[:filename]}"
    end
  end

  describe "existing" do
    let (:existing) { OpenStruct.new(:image_meta_data => {:original => {:uid=>"/uid/1234.jpg"}}) }
    subject { Attachment.new(existing.image_meta_data, :model => existing) }

    it { subject[:original].uid.must_equal "/uid/1234.jpg" } # notice that #uid_from is not called.
  end

  describe "new" do
    subject { Attachment.new(nil, :filename => "apotomo.png", :model => OpenStruct.new) } # you can pass options into Attachment::new that may be used in #build_uid

    it { subject[:original].uid.must_equal "OpenStruct/uid/original/apotomo.png" }
  end
end