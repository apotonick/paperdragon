module Paperdragon
  class Attachment
    class << self
      attr_accessor :file_class # !!! this is NOT inheritable (do we need that?).
    end

    module InstanceMethods
      def initialize(metadata)
        @metadata = Metadata.new(metadata)
      end

      def [](style)
        file_metadata = @metadata[style]

        uid = file_metadata[:uid] || build_uri(style)
        self.class.file_class.new(uid)
      end

    private
      def build_uri(*args)
        uid_from(*args)
      end

      def uid_from(style)
        "uid/#{style}"
      end
    end
    include InstanceMethods


    module Model
      def initialize(model)
        @model = model
        super(model.image_meta_data) # only dependency to model.
      end

      def build_uri(style)
        uid_from(@model, style)
      end
    end
  end
end