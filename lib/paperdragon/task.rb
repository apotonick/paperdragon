module Paperdragon
  class Task
    def initialize(attachment, upload=nil)
      @attachment = attachment
      @upload       = upload
      @metadata   = {}
    end

    attr_reader :metadata

    # process!(style, [*args,] &block) :
    #   version = CoverGirl::Photo.new(@model, style, *args)
    #   metadata = version.process!(upload, &block)
    #   merge! {style => metadata}
    def process!(style, &block)
      @metadata.merge!(style => file(style).process!(upload, &block))
    end

    def reprocess!(style, original, fingerprint, &block)
      version = file(style)
      new_uid = version.uid_for(fingerprint) # requirement for the File subclass!

      @metadata.merge!(style => version.reprocess!(original, new_uid, &block))
    end

    def rename!(style, fingerprint, &block)
      version = file(style)
      new_uid = version.uid_for(fingerprint) # requirement for the File subclass!

      @metadata.merge!(style => version.rename!(new_uid, &block))
    end

  private
    def file(style)
      @attachment[style]
    end

    def upload
      @upload or raise MissingUploadError.new("You called #process! but didn't pass an uploaded file to Attachment#task.")
    end
  end
end