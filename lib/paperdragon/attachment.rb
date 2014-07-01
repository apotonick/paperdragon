require 'uber/inheritable_attr'

module Paperdragon
  class Attachment
    extend Uber::InheritableAttr
    inheritable_attr :file_class #, strategy: ->{ tap{} }
    self.file_class = ::Paperdragon::File # default value. # !!! be careful, this gets cloned in subclasses and thereby becomes a subclass of PD:File.

    module InstanceMethods
      def initialize(metadata)
        @metadata = Metadata.new(metadata)
      end

      def [](style)
        file_metadata = @metadata[style]

        uid = file_metadata[:uid] || build_uid(style)
        self.class.file_class.new(uid, file_metadata)
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