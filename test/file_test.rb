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

  let (:logo) { Pathname("test/fixtures/apotomo.png") }

  # process! saves file
  # TODO: remote storage, server root, etc.
  # todo: test block.
  let (:uid) { generate_uid }


  describe "#process!" do
    let (:file) { file = Paperdragon::File.new(uid, logo) }

    it do
      job = file.process!

      job.must_be_kind_of Dragonfly::Job
      job.size.must_equal 9632
      exists?(uid).must_equal true
    end

    # block
    it do
      # puts file.data.size # 9632 bytes
      file.process! do |job|
        job.thumb!("16x16")
      end

      # fixme: wrong data:
      file.data.size.must_equal 457 # smaller after thumb!
    end
  end


  describe "#delete!" do
    it do
      file = Paperdragon::File.new(uid, logo)
      file.process!
      exists?(uid).must_equal true

      job = Paperdragon::File.new(uid).delete!

      job.must_equal nil
      exists?(uid).must_equal false
    end
  end


  describe "#reprocess!" do
    # existing:
    let (:file)     { Paperdragon::File.new(uid) }
    let (:original) { Paperdragon::File.new(uid, logo) }

    before do
      original.process!
      exists?(uid).must_equal true
    end

    it do
      job = file.reprocess!(original, new_uid = generate_uid)

      job.must_be_kind_of Dragonfly::Job
      exists?(uid).must_equal false # deleted
      exists?(new_uid).must_equal true
    end

    it do
      job = file.reprocess!(original, new_uid = generate_uid) do |j|
        j.thumb!("16x16")
      end

      file.data.size.must_equal 457
    end
  end


  def exists?(uid)
    File.exists?("public/paperdragon/" + uid)
  end

  def generate_uid
    Dragonfly.app.datastore.send(:relative_path_for, "aptomo.png")
  end
end