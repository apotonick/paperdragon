require 'test_helper'

class TaskSpec < MiniTest::Spec
  class Attachment < Paperdragon::Attachment
    class File < Paperdragon::File
    end
    self.file_class= File
  end

  let (:logo) { Pathname("test/fixtures/apotomo.png") }


  # #task allows block and returns metadata hash.
  describe "#task" do
    it do
      Attachment.new(nil).task(logo) do |t|
        t.process!(:original)
        t.process!(:thumb) { |j| j.thumb!("16x16") }
      end.must_equal({:original=>{:width=>216, :height=>63, :uid=>"original-apotomo.png", :content_type=>"image/png"}, :thumb=>{:width=>16, :height=>5, :uid=>"thumb-apotomo.png", :content_type=>"image/png"}})
    end
  end

  # task without block
  let (:subject) { Attachment.new(nil).task(logo) }

  describe "#process!" do
    it do
      subject.process!(:original)
      subject.process!(:thumb) { |j| j.thumb!("16x16") }

      subject.metadata_hash.must_equal({:original=>{:width=>216, :height=>63, :uid=>"original-apotomo.png", :content_type=>"image/png"}, :thumb=>{:width=>16, :height=>5, :uid=>"thumb-apotomo.png", :content_type=>"image/png"}})
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

    subject { Attachment.new({
      :original=>{:uid=>"original/pic"}, :thumb=>{:uid=>"original/thumb"}}).task
    }

    # FIXME: fingerprint should be added before .png suffix, idiot!
    it do
      subject.reprocess!(:original, "/2/original", original)
      subject.reprocess!(:thumb,    "/2/thumb",    original) { |j| j.thumb!("16x16") }

      # it
      subject.metadata_hash.must_equal({:original=>{:width=>216, :height=>63, :uid=>"original/pic-/2/original", :content_type=>"application/octet-stream"}, :thumb=>{:width=>16, :height=>5, :uid=>"original/thumb-/2/thumb", :content_type=>"application/octet-stream"}})
      # it
      # exists?(original.uri).must_equal false # deleted
      # exists?(new_uid).must_equal true
    end

    # don't pass in fingerprint+original.
    it do
      subject.reprocess!(:thumb) { |j| j.thumb!("24x24") }
      subject.metadata_hash.must_equal({:original=>{:uid=>"original/pic"}, :thumb=>{:width=>24, :height=>7, :uid=>"original/thumb", :content_type=>"application/octet-stream"}})
    end

    # only process one, should return entire metadata hash
    it do
      subject.reprocess!(:thumb, "-new") { |j| j.thumb!("24x24") }
      subject.metadata_hash.must_equal({:original=>{:uid=>"original/pic"}, :thumb=>{:width=>24, :height=>7, :uid=>"original/thumb--new", :content_type=>"application/octet-stream"}})

      # original must be unchanged
    end

    # octet filetype?
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
