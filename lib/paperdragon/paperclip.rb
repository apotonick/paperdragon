module Paperdragon
  class Paperclip

    # Compute a UID to be compatible with paperclip. This class is meant to be subclassed so you can write
    # your specific file path.
    class Uid
      # "/system/:class/:attachment/:id_partition/:style/:filename"
      def initialize(options)
        @class_name  = options[:class]
        @attachment  = options[:attachment]
        @id          = options[:id]
        @style       = options[:style]
        @updated_at  = options[:updated_at]
        @file_name   = options[:file_name]
        @hash_secret = options[:hash_secret]
      end

      def call
        # default:
        # system/:class/:attachment/:id_partition/:style/:filename
        "#{root}/#{class_name}/#{attachment}/#{id_partition}/#{hash}/#{style}/#{file_name}"
      end

    private
      attr_reader :class_name, :attachment, :id, :style, :file_name, :hash_secret, :updated_at

      def root
        "system"
      end

      def id_partition
        IdPartition.call(id)
      end

      def hash
        HashKey.call(hash_secret, class_name, attachment, id, style, updated_at)
      end


      class IdPartition
        def self.call(id)
          ("%09d" % id).scan(/\d{3}/).join("/") # FIXME: only works with integers.
        end
      end


      # ":class/:attachment/:id/:style/:updated_at"
      class HashKey
        require 'openssl' unless defined?(OpenSSL)

        # cover_girls/images/4841/thumb/1402617353
        def self.call(secret, class_name, attachment, id, style, updated_at)
          data = "#{class_name}/#{attachment}/#{id}/#{style}/#{updated_at}"
          OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, secret, data)
        end
      end
    end
  end
end