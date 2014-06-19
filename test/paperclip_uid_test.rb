require 'test_helper'

require 'paperdragon/paperclip'

class PaperclipUidTest < MiniTest::Spec
  it { Paperdragon::Paperclip::Uid.new(:class => :avatars, :attachment => :image, :id => 1234,
    :style => :original, :updated_at => Time.parse("20-06-2014 9:40:59").to_i,
    :file_name => "kristylee.jpg", :hash_secret => "secret" ).
    call.must_equal "system/avatars/image/000/001/234/9bf15e5874b3234c133f7500e6d615747f709e64/original/kristylee.jpg" }
end