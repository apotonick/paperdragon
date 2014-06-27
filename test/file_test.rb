require 'test_helper'

Dragonfly.app.configure do

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
  it "what" do
    uid = Dragonfly.app.datastore.send( :relative_path_for, "aptomo.png")

    file = Paperdragon::File.new(uid, logo)
    file.process!

    # file.url.must_equal uid
    puts uid
    File.exists?("public/paperdragon/" + uid).must_equal true
  end
end