require 'test_helper'

class MetadataTest < MiniTest::Spec
  describe "valid" do
    let (:valid) {
      {
        :original=>{:width=>960, :height=>960, :uid=>"403661339/kristylee-38.jpg", :content_type=>"image/jpeg", :size=>198299},
        :thumb   =>{:width=>191, :height=>191, :uid=>"ds3661339/kristylee-38.jpg", :content_type=>"image/jpeg", :size=>18132}
      }
    }

    subject { Paperdragon::Metadata[valid] }

    it { subject.populated?.must_equal true }
    it { subject[:original][:width].must_equal 960 }
    it { subject[:original][:uid].must_equal "403661339/kristylee-38.jpg" }
    it { subject[:thumb][:uid].must_equal "ds3661339/kristylee-38.jpg" }

    it { subject[:page].must_equal({}) }
    it { subject[:page][:width].must_equal nil }
  end


  describe "nil" do
    subject { Paperdragon::Metadata[nil] }

    it { subject.populated?.must_equal false }
    it { subject[:page].must_equal({}) }
    it { subject[:page][:width].must_equal nil }
  end

  describe "empty hash" do
    subject { Paperdragon::Metadata[{}] }

    it { subject.populated?.must_equal false }
    it { subject[:page].must_equal({}) }
    it { subject[:page][:width].must_equal nil }
  end

  let (:original) { {:original => {}} }

  # #dup
  # don't change original hash.
  it do
    Paperdragon::Metadata[original].dup.merge!(:additional => {})
    original[:additional].must_equal nil
  end

  # #to_hash
  it { Paperdragon::Metadata[original].to_hash.must_equal({:original=>{}}) }
  it { Paperdragon::Metadata[original].to_hash.class.must_equal(Hash) }
end