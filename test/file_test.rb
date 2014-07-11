require 'test_helper'

Dragonfly.app.configure do
  plugin :imagemagick

  #url_host 'http://some.domain.com:4000'

  datastore :file,
    :server_root => 'public',
    :root_path => 'public/paperdragon'
end

class PaperdragonFileTest < MiniTest::Spec
  it { Paperdragon::File.new("123").uid.must_equal "123" }
  it { Paperdragon::File.new("123").url.must_equal "/paperdragon/123" } # FIXME: how to add host?
  it { Paperdragon::File.new("123") }

  describe "#metadata" do
    it { Paperdragon::File.new("123").metadata.must_equal({}) }
    it { Paperdragon::File.new("123", :width => 16).metadata.must_equal({:width => 16}) }
  end

  describe "#data" do
    it do
      Paperdragon::File.new(uid).process!(logo)
      Paperdragon::File.new(uid).data.size.must_equal 9632
    end
  end

  let (:logo) { Pathname("test/fixtures/apotomo.png") }

  # process! saves file
  # TODO: remote storage, server root, etc.
  let (:uid) { generate_uid }


  describe "#process!" do
    let (:file) { file = Paperdragon::File.new(uid) }

    it do
      metadata = file.process!(logo)

      metadata.must_equal({:width=>216, :height=>63, :uid=>uid, :content_type=>"image/png", :size=>9632})
      exists?(uid).must_equal true
    end

    # block
    it do
      # puts file.data.size # 9632 bytes
      file.process!(logo) do |job|
        job.thumb!("16x16")
      end

      file.data.size.must_equal 457 # smaller after thumb!
    end

    # additional metadata
    it do
      file.process!(logo, :cropping => "16x16") do |job|
        job.thumb!("16x16")
      end.must_equal({:width=>16, :height=>5, :uid=>uid, :content_type=>"image/png", :size=>457, :cropping=>"16x16"})
    end
  end


  describe "#delete!" do
    it do
      file = Paperdragon::File.new(uid)
      file.process!(logo)
      exists?(uid).must_equal true

      job = Paperdragon::File.new(uid).delete!

      job.must_equal nil
      exists?(uid).must_equal false
    end
  end


  describe "#reprocess!" do
    # existing:
    let (:file)     { Paperdragon::File.new(uid) }
    let (:original) { Paperdragon::File.new("original/#{uid}") }
    let (:new_uid) { generate_uid }

    before do
      original.process!(logo) # original/uid exists.
      exists?(original.uid).must_equal true
      file.process!(logo)
      exists?(file.uid).must_equal true # file to be reprocessed exists (to test delete).
    end

    it do
      metadata = file.reprocess!(original, new_uid)

      # it
      metadata.must_equal({:width=>216, :height=>63, :uid=>new_uid, :content_type=>"application/octet-stream", :size=>9632})
      # it
      exists?(uid).must_equal false # deleted
      exists?(new_uid).must_equal true
    end

    it do
      job = file.reprocess!(original, new_uid) do |j|
        j.thumb!("16x16")

      end

      file.data.size.must_equal 457
    end
  end


  describe "#rename!" do
    # existing:
    let (:file)     { Paperdragon::File.new(uid, :size => 99) }
    let (:original) { Paperdragon::File.new(uid) }
    let (:new_uid) { generate_uid }

    before do
      original.process!(logo)
      exists?(uid).must_equal true
    end

    it do
      metadata = file.rename!(new_uid) do |uid, new_uid|
        File.rename("public/paperdragon/"+uid, "public/paperdragon/"+new_uid) # DISCUSS: should that be simpler?
      end

      # it
      # metadata.must_equal({:width=>216, :height=>63, :uid=>new_uid, :content_type=>"application/octet-stream", :size=>9632})
      metadata.must_equal(:uid=>new_uid, :size => 99) # we DON'T fetch original metadata here anymore.

      exists?(uid).must_equal false # deleted
      exists?(new_uid).must_equal true
    end
  end
end