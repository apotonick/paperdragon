require 'test_helper'

class TaskSpec < MiniTest::Spec
  class Attachment < Paperdragon::Attachment
    class File < Paperdragon::File
    end
    self.file_class= File

  private
    def uid_from(style)
      "/uid/#{style}"
    end
  end

  let (:logo) { Pathname("test/fixtures/apotomo.png") }
  let (:subject) { Attachment.new(nil).task(logo) }

  describe "#process!" do
    it do
      subject.process!(:original)
      subject.process!(:thumb) { |j| j.thumb!("16x16") }

      subject.metadata.must_equal({:original=>{:width=>216, :height=>63, :uid=>"/uid/original", :content_type=>"image/png", :size=>9632}, :thumb=>{:width=>16, :height=>5, :uid=>"/uid/thumb", :content_type=>"image/png", :size=>457}})
    end

    it do
      assert_raises Paperdragon::MissingUploadError do
        Attachment.new(nil).task.process!(:original)
      end
    end
  end
end
