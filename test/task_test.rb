require 'test_helper'

class TaskSpec < MiniTest::Spec
  class Attachment < Paperdragon::Attachment
    class File < Paperdragon::File
    end
    self.file_class= File
  end

  let (:logo) { Pathname("test/fixtures/apotomo.png") }
  let (:subject) { Attachment.new(nil).task(logo) }

  describe "#process!" do
    it do
      subject.process!(:original)
      subject.process!(:thumb) { |j| j.thumb!("16x16") }

      subject.metadata.must_equal({:original=>{:width=>216, :height=>63, :uid=>"original-apotomo.png", :content_type=>"image/png"}, :thumb=>{:width=>16, :height=>5, :uid=>"thumb-apotomo.png", :content_type=>"image/png"}})
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

    let (:subject) { Attachment.new({
      :original=>{:uid=>"original/pic"}, :thumb=>{:uid=>"original/pic"}}).task
    }

    it do
      subject.reprocess!(:original, original, "/2/original")
      subject.reprocess!(:thumb,    original, "/2/thumb") { |j| j.thumb!("16x16") }

      # it
      subject.metadata.must_equal({:original=>{:width=>216, :height=>63, :uid=>"original/pic-/2/original", :content_type=>"application/octet-stream"}, :thumb=>{:width=>16, :height=>5, :uid=>"original/pic-/2/thumb", :content_type=>"application/octet-stream"}})
      # it
      # exists?(original.uri).must_equal false # deleted
      # exists?(new_uid).must_equal true
    end
  end


  describe "#rename!" do
    before do
      attachment = Paperdragon::Attachment.new(nil)
      @upload_task = attachment.task(logo)
      metadata = @upload_task.process!(:original).must_equal({:original=>{:width=>216, :height=>63, :uid=>"original-apotomo.png", :content_type=>"image/png"}})

      # we do not update the attachment from task.
      attachment = Paperdragon::Attachment.new(@upload_task.metadata)
      exists?(attachment[:original].uid).must_equal true
    end

    let (:metadata) { @upload_task.metadata }

    # let (:subject) { Attachment.new(nil).task }
    it do
      attachment = Paperdragon::Attachment.new(metadata) # {:original=>{:width=>216, :height=>63, :uid=>"uid/original", :content_type=>"image/png", :size=>9632}}
      task = attachment.task
      task.rename!(:original, "new") { |uid, new_uid|
        File.rename("public/paperdragon/"+uid, "public/paperdragon/"+new_uid)
      }.must_equal({:original=>{:width=>216, :height=>63, :uid=>"original-apotomo.png-new", :content_type=>"image/png"}})
    end
  end
end
