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
      end.must_equal({:original=>{:width=>216, :height=>63, :uid=>"original-apotomo.png"}, :thumb=>{:width=>16, :height=>5, :uid=>"thumb-apotomo.png"}})
    end

    # modify metadata in task
    it do
      Attachment.new({:processing => true, :approved => true}).task(logo) do |t|
        t.process!(:original)
        t.metadata.delete(:processing)
      end.must_equal({:original=>{:width=>216, :height=>63, :uid=>"original-apotomo.png"}, :approved => true})
    end

  end

  # task without block
  let (:subject) { Attachment.new(nil).task(logo) }

  describe "#process!" do
    it do
      subject.process!(:original)
      subject.process!(:thumb) { |j| j.thumb!("16x16") }

      subject.metadata_hash.must_equal({:original=>{:width=>216, :height=>63, :uid=>"original-apotomo.png"}, :thumb=>{:width=>16, :height=>5, :uid=>"thumb-apotomo.png"}})

      puts "our tset"
      # calling #process! with existing metadata.
      task = Attachment.new(subject.metadata_hash).task(Pathname("test/fixtures/trb.png"))
      task.process!(:thumb) { |j| j.thumb!("48x48") }
      task.metadata_hash.must_equal({:original=>{:width=>216, :height=>63, :uid=>"original-apotomo.png"}, :thumb=>{:width=>48, :height=>48, :uid=>"thumb-trb.png"}})
    end

    it do
      assert_raises Paperdragon::MissingUploadError do
        Attachment.new(nil).task.process!(:original)
      end
    end
  end


  describe "#reprocess!" do
    let (:original) { Paperdragon::File.new("original/pic.jpg") }

    before do
      original.process!(logo) # original/uid exists.
      exists?(original.uid).must_equal true
    end

    subject { Attachment.new({
      :original=>{:uid=>"original/pic.jpg"}, :thumb=>{:uid=>"original/thumb.jpg"}, :bigger=>{:uid=>"original/bigger.jpg"}}).task
    }

    it do
      subject.reprocess!(:original, "1", original)
      subject.reprocess!(:thumb,    "1",    original) { |j| j.thumb!("16x16") }

      # FIXME: fingerprint should be added before .png suffix.
      subject.metadata_hash.must_equal({:original=>{:width=>216, :height=>63, :uid=>"original/pic-1.jpg"}, :thumb=>{:width=>16, :height=>5, :uid=>"original/thumb-1.jpg"}, :bigger=>{:uid=>"original/bigger.jpg"}})

      # exists?(original.uri).must_equal false # deleted
      # exists?(new_uid).must_equal true
    end

    # don't pass in fingerprint+original.
    it do
      subject.reprocess!(:thumb) { |j| j.thumb!("24x24") }
      subject.reprocess!(:bigger) { |j| j.thumb!("48x48") }

      subject.metadata_hash.must_equal({:original=>{:uid=>"original/pic.jpg"}, :thumb=>{:width=>24, :height=>7, :uid=>"original/thumb-.jpg"}, :bigger=>{:uid=>"original/bigger-.jpg", :width=>48, :height=>14}})
    end

    # don't pass in original, this must NOT reload the original file more than once!
    it do
      subject.reprocess!(:thumb, 1) { |j| j.thumb!("24x24") }
      File.unlink("public/paperdragon/#{original.uid}") # removing means the original MUST be cached for next step.
      subject.reprocess!(:bigger, 1) { |j| j.thumb!("48x48") }

      subject.metadata_hash.must_equal(
        {:original=>{:uid=>"original/pic.jpg"}, :thumb=>{:width=>24, :height=>7, :uid=>"original/thumb-1.jpg"}, :bigger=>{:uid=>"original/bigger-1.jpg", :width=>48, :height=>14}})
    end

    # only process one, should return entire metadata hash
    it do
      subject.reprocess!(:thumb, "new") { |j| j.thumb!("24x24") }
      subject.metadata_hash.must_equal({:original=>{:uid=>"original/pic.jpg"}, :thumb=>{:width=>24, :height=>7, :uid=>"original/thumb-new.jpg"}, :bigger=>{:uid=>"original/bigger.jpg"}})

      # original must be unchanged
      exists?(Attachment.new(subject.metadata_hash)[:original].uid).must_equal true
    end

    # #rebuild_uid tries to replace existing fingerprint (default behaviour).
    it do
      subject.reprocess!(:thumb, "1234567890") { |j| j.thumb!("24x24") }
      metadata = subject.metadata_hash
      metadata.must_equal({:original=>{:uid=>"original/pic.jpg"}, :thumb=>{:width=>24, :height=>7, :uid=>"original/thumb-1234567890.jpg"}, :bigger=>{:uid=>"original/bigger.jpg"}})

      # this might happen in the next request.
      subject = Attachment.new(metadata).task
      subject.reprocess!(:thumb, "0987654321") { |j| j.thumb!("24x24") }
      subject.metadata_hash.must_equal({:original=>{:uid=>"original/pic.jpg"}, :thumb=>{:width=>24, :height=>7, :uid=>"original/thumb-0987654321.jpg"}, :bigger=>{:uid=>"original/bigger.jpg"}})
    end

    # #rebuild_uid eats integers.
    it { subject.reprocess!(:thumb, 1234081599) { |j| j.thumb!("24x24") }.must_equal({:original=>{:uid=>"original/pic.jpg"}, :thumb=>{:width=>24, :height=>7, :uid=>"original/thumb-1234081599.jpg"}, :bigger=>{:uid=>"original/bigger.jpg"}}) }
  end


  describe "#rename!" do
    before do
      attachment = Paperdragon::Attachment.new(nil)
      @upload_task = attachment.task(logo)
      metadata = @upload_task.process!(:original).must_equal({:original=>{:width=>216, :height=>63, :uid=>"original-apotomo.png"}})

      # we do not update the attachment from task.
      attachment = Paperdragon::Attachment.new(@upload_task.metadata)
      exists?(attachment[:original].uid).must_equal true
    end

    let (:metadata) { @upload_task.metadata }

    # let (:subject) { Attachment.new(nil).task }
    it do
      attachment = Paperdragon::Attachment.new(metadata) # {:original=>{:width=>216, :height=>63, :uid=>"uid/original", :size=>9632}}
      task = attachment.task
      task.rename!(:original, "new") { |uid, new_uid|
        File.rename("public/paperdragon/"+uid, "public/paperdragon/"+new_uid)
      }.must_equal({:original=>{:width=>216, :height=>63, :uid=>"original-apotomo-new.png"}})
    end
  end
end
