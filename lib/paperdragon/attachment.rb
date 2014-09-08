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
        @metadata = Metadata[metadata]
        @options  = options # to be used in #(re)build_uid for your convenience. # DISCUSS: we pass in the model here - is that what we want?
      end
      attr_reader :metadata # TODO: test me.

      def [](style, file=nil) # not sure if i like passing file here, consider this method signature semi-public.
        file_metadata = @metadata[style]

        uid = file_metadata[:uid] || uid_from(style, file)
        self.class.file_class.new(uid, file_metadata)
      end

      # DSL method providing the task instance.
      # When called with block, it yields the task and returns the generated metadata.
      def task(upload=nil, &block)
        task = Task.new(self, upload, &block)

        return task unless block_given?
        task.metadata_hash
      end

      # Computes UID when File doesn't have one, yet. Called in #initialize.
      def uid_from(*args)
        build_uid(*args)
      end

      # Per default, paperdragon tries to increment the fingerprint in the file name, identified by
      # the pattern <tt>/-\d{10}/</tt> just before the filename extension (.png).
      def rebuild_uid(file, fingerprint=nil) # the signature of this method is to be considered semi-private.
        ext  = ::File.extname(file.uid)
        name = ::File.basename(file.uid, ext)

        if fingerprint and matches = name.match(/-(\d{10})$/)
          return file.uid.sub(matches[1], fingerprint.to_s)
        end

        file.uid.sub(name, "#{name}-#{fingerprint}")
      end

      def exists? # should be #uploaded? or #stored?
        # not sure if i like that kind of state here, so consider method semi-public.
        @metadata.populated?
      end

    private
      attr_reader :options

      def build_uid(style, file)
        # can we use Dragonfly's API here?
        "#{style}-#{Dragonfly::TempObject.new(file).original_filename}"
      end
    end


    module SanitizeUid
      def uid_from(*args)
        sanitize(super)
      end

      def sanitize(uid)
        #URI::encode(uid) # this is wrong, we can't send %21 in path to S3!
        uid.gsub(/(#|\?)/, "_") # escape # and ?, only.
      end
    end


    include InstanceMethods
    include SanitizeUid # overrides #uid_from.
  end
end