module Paperdragon
  class Attachment
    class << self
      attr_accessor :file_class # !!! this is NOT inheritable (do we need that?).
    end

    def initialize(metadata)
      @metadata = Metadata.new(metadata)
    end

    def [](style)
      file_metadata = @metadata[style]

      uid = file_metadata[:uid] || uid_from(style, @metadata)
      self.class.file_class.new(uid)
    end

  private
    def uid_from(style, metadata)
      "uid/#{style}"
    end
  end
end