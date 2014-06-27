require 'test_helper'

class MetadataTest < MiniTest::Spec
  describe "valid" do
    let (:valid) {
      {
        :original=>{:width=>960, :height=>960, :uid=>"403661339/kristylee-38.jpg", :content_type=>"image/jpeg", :size=>198299},
        :thumb   =>{:width=>191, :height=>191, :uid=>"ds3661339/kristylee-38.jpg", :content_type=>"image/jpeg", :size=>18132}
      }
    }

    subject { Paperdragon::Metadata.new(valid) }

    it { subject[:original][:width].must_equal 960 }
    it { subject[:original][:uid].must_equal "403661339/kristylee-38.jpg" }
    it { subject[:thumb][:uid].must_equal "ds3661339/kristylee-38.jpg" }

    it { subject[:page].must_equal({}) }
    it { subject[:page][:width].must_equal nil }
  end


  describe "nil" do
    subject { Paperdragon::Metadata.new(nil) }

    it { subject[:page].must_equal({}) }
    it { subject[:page][:width].must_equal nil }
  end
end