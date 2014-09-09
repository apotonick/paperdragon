module Paperdragon
  # Gives a simple API for processing multiple versions of a single attachment.
  class Task
    def initialize(attachment, upload=nil)
      @attachment = attachment
      @upload     = upload
      @metadata   = attachment.metadata.dup # DISCUSS: keep this dependency?

      yield self if block_given?
    end

    attr_reader :metadata
    def metadata_hash # semi-private, might be removed.
      metadata.to_hash
    end

    # process!(style, [*args,] &block) :
    #   version = CoverGirl::Photo.new(@model, style, *args)
    #   metadata = version.process!(upload, &block)
    #   merge! {style => metadata}
    def process!(style, &block)
      version = file(style, upload)
      new_uid = new_uid_for(style, version) # new uid when overwriting existing attachment.

      @metadata.merge!(style => version.process!(upload, new_uid, &block))
    end

    # fingerprint optional => filename is gonna remain the same
    # original nil => use [:original]
    def reprocess!(style, fingerprint=nil, original=nil, &block)
      @original ||= file(:original) # this is cached per task instance.
      version     = file(style)
      new_uid     = @attachment.rebuild_uid(version, fingerprint)

      @metadata.merge!(style => version.reprocess!(new_uid, @original, &block))
    end

    def rename!(style, fingerprint, &block)
      version = file(style)
      new_uid = @attachment.rebuild_uid(version, fingerprint)

      @metadata.merge!(style => version.rename!(new_uid, &block))
    end

  private
    def file(style, upload=nil)
      @attachment[style, upload]
    end

    def upload
      @upload or raise MissingUploadError.new("You called #process! but didn't pass an uploaded file to Attachment#task.")
    end

    # Returns new UID for new file when overriding an existing attachment with #process!.
    def new_uid_for(style, version)
      # check if UID is present in existing metadata.
      @attachment.metadata[style][:uid] ? @attachment.uid_from(style, upload) : nil # DISCUSS: move to Attachment?
    end
  end
end