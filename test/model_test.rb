require 'test_helper'

require 'paperdragon/model'
class PaperdragonModelTest < MiniTest::Spec
  class Avatar
    class Photo # TODO: replace with Paperdragon::File
      def initialize(model, style)
        @uid = "#{model.class}-#{style}"
      end

      def url
        @uid
      end
    end


    include Paperdragon::Model
    processable :image, Photo
  end

  it { Avatar.new.image(:thumb).url.must_equal "PaperdragonModelTest::Avatar-thumb" }
end