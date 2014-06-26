require 'test_helper'

require 'paperdragon/paperclip'

class PaperclipUidTest < MiniTest::Spec
  Uid = Paperdragon::Paperclip::Uid

  let (:options) { {:class_name => :avatars, :attachment => :image, :id => 1234,
    :style => :original, :updated_at => Time.parse("20-06-2014 9:40:59").to_i,
    :file_name => "kristylee.jpg", :hash_secret => "secret"} }

  it { Uid.from(options).call.
    must_equal "system/avatars/image/000/001/234/9bf15e5874b3234c133f7500e6d615747f709e64/original/kristylee.jpg" }

  # describe "#dup" do
  #   let (:uid) { Uid.new(options) }

  #   it do
  #     uid.dup(:class_name => :portraits).call.
  #       must_equal "system/portraits/image/000/001/234/df0038432073272a49b70a6461a83b4c9b4102ad/original/kristylee.jpg"

  #     # doesn't alter the original UID.
  #     uid.call.must_equal "system/avatars/image/000/001/234/9bf15e5874b3234c133f7500e6d615747f709e64/original/kristylee.jpg"
  #   end
  # end



  class UidWithFingerprint < Paperdragon::Paperclip::Uid
    class Computer < Computer
      def call
        "#{root}/#{class_name}/#{attachment}/#{id_partition}/#{hash}/#{style}/#{fingerprint}-#{file_name}"
      end
    end

    def self.from(options, computer=Computer)
      super
    end
  end

  it { UidWithFingerprint.from(options.merge(:fingerprint => 8675309)).call.
    must_equal "system/avatars/image/000/001/234/9bf15e5874b3234c133f7500e6d615747f709e64/original/8675309-kristylee.jpg" }
end


class PaperclipModelTest < MiniTest::Spec
  class Avatar
    class Photo # TODO: replace with Paperdragon::File
      def initialize(model, style)
        @uid = "#{model.class}-#{style}"
      end

      def url
        @uid
      end
    end


    include Paperdragon::Paperclip::Model
    processable :image, Photo
  end

  # old paperclip style
  it { Avatar.new.image.url(:thumb).must_equal "PaperclipModelTest::Avatar-thumb" }

  # paperdragon style
  it { Avatar.new.image(:thumb).url.must_equal "PaperclipModelTest::Avatar-thumb" }
end