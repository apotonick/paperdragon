module Paperdragon
  # Gives a simple API for processing multiple versions of a single attachment.
  class Task
    def initialize(attachment, upload=nil)
      @attachment = attachment
      @upload     = upload
      @metadata   = attachment.metadata.dup

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
      @metadata.merge!(style => file(style, upload).process!(upload, &block))
    end

    # fingerprint optional => filename is gonna remain the same
    # original nil => use [:original]
    def reprocess!(style, fingerprint=nil, original=nil, &block)
      original ||= file(:original)
      version    = file(style)
      new_uid    = @attachment.rebuild_uid(version, fingerprint)

      @metadata.merge!(style => version.reprocess!(new_uid, original, &block))
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
  end
end