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

        uid = file_metadata[:uid] || build_uid(style)
        self.class.file_class.new(uid)
      end

      def task(upload=nil)
        Task.new(self, upload)
      end

      # def rebuild_uid(style, old_uid, *args)
      def rebuild_uid(file, fingerprint)
        "#{file.uid}-#{fingerprint}"
      end

    private
      def build_uid(*args)
        uid_from(*args)
      end

      def uid_from(style)
        "uid/#{style}"
      end
    end
    include InstanceMethods


    # Grab model.image_meta_data in initialize. If this is not present, call #uid_from(model, style)
    module Model
      def initialize(model)
        @model = model
        super(model.image_meta_data) # only dependency to model.
      end

      def build_uid(style)
        uid_from(@model, style)
      end
    end
  end
end