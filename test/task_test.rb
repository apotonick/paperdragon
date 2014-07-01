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


  describe "#reprocess!" do
    let (:original) { Paperdragon::File.new("original/pic") }

    before do
      original.process!(logo) # original/uid exists.
      exists?(original.uid).must_equal true
    end

    let (:subject) { Attachment.new(nil).task }
    it do
      subject.reprocess!(:original, original, "/2/original")
      subject.reprocess!(:thumb,    original, "/2/thumb") { |j| j.thumb!("16x16") }

      # it
      subject.metadata.must_equal({:original=>{:width=>216, :height=>63, :uid=>"/uid/original-/2/original", :content_type=>"application/octet-stream", :size=>9632}, :thumb=>{:width=>16, :height=>5, :uid=>"/uid/thumb-/2/thumb", :content_type=>"application/octet-stream", :size=>457}})
      # it
      # exists?(original.uri).must_equal false # deleted
      # exists?(new_uid).must_equal true
    end
  end
end
