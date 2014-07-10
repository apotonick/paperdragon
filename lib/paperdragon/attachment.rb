require 'uber/inheritable_attr'

module Paperdragon
  # Override #build_uid / #rebuild_uid.
  # Note that we only encode the UID when computing it the first time. It is then stored encoded
  # and no escaping happens at any time after that.
  # You may use options.
  # only saves metadata, does not know about model.
  # Attachment is a builder for File and knows about metadata. It is responsible for creating UID if metadata is empty.
  class Attachment
    extend Uber::InheritableAttr
    inheritable_attr :file_class #, strategy: ->{ tap{} }
    self.file_class = ::Paperdragon::File # default value. # !!! be careful, this gets cloned in subclasses and thereby becomes a subclass of PD:File.


    module InstanceMethods
      def initialize(metadata, options={})
        @metadata = Metadata.new(@stored = metadata)
        @options  = options # to be used in #(re)build_uid for your convenience.
      end

      def [](style)
        file_metadata = @metadata[style]

        uid = file_metadata[:uid] || uid_from(style)
        self.class.file_class.new(uid, file_metadata)
      end

      def task(upload=nil)
        Task.new(self, upload)
      end

      # def rebuild_uid(style, old_uid, *args)
      def rebuild_uid(file, fingerprint)
        "#{file.uid}-#{fingerprint}"
      end

      def exists? # should be #uploaded? or #stored?
        # not sure if i like that kind of state here, so consider method semi-public.
        !! @stored
      end

    private
      attr_reader :options

      # Computes UID when File doesn't have one, yet. Called in #initialize.
      def uid_from(*args)
        build_uid(*args)
      end

      def build_uid(style)
        "uid/#{style}"
      end
    end


    module SanitizeUid
      def uid_from(*args)
        sanitize(super)
      end

      def sanitize(uid)
        URI::encode(uid)
      end
    end


    include InstanceMethods
    include SanitizeUid # overrides #uid_from.


    # Grab model.image_meta_data in initialize. If this is not present, call #uid_from(model, style)
    module Model
      def initialize(model, *args)
        @model = model
        super(model.image_meta_data, *args) # only dependency to model.
      end

    private
      attr_reader :model
    end
  end
end