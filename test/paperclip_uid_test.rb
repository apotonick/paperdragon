require 'test_helper'

require 'paperdragon/paperclip'

class PaperclipUidTest < MiniTest::Spec
  let (:options) { {:class_name => :avatars, :attachment => :image, :id => 1234,
    :style => :original, :updated_at => Time.parse("20-06-2014 9:40:59").to_i,
    :file_name => "kristylee.jpg", :hash_secret => "secret"} }

  it { Paperdragon::Paperclip::Uid.new(options).call.
    must_equal "system/avatars/image/000/001/234/9bf15e5874b3234c133f7500e6d615747f709e64/original/kristylee.jpg" }


  class UidWithFingerprint < Paperdragon::Paperclip::Uid
    def call
      "#{root}/#{class_name}/#{attachment}/#{id_partition}/#{hash}/#{style}/#{fingerprint}-#{file_name}"
    end
  end

  it { UidWithFingerprint.new(options.merge(:fingerprint => 8675309)).call.
    must_equal "system/avatars/image/000/001/234/9bf15e5874b3234c133f7500e6d615747f709e64/original/8675309-kristylee.jpg" }

end