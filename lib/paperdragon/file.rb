module Paperdragon
  # A physical file with a UID.
  class File
    def initialize(uid)
      @uid  = uid
      @data = nil
    end

    attr_reader :uid

    def url(opts={})
      Dragonfly.app.remote_url_for(uid, opts)
    end

    def data
      puts "........................FETCH  (data): #{uid}, #{@data ? :cached : (:fetching)}"
      @data ||= Dragonfly.app.fetch(uid).data
    end

    # attr_reader :meta_data

    require 'paperdragon/file/operations'
    include Process
    include Delete
    include Reprocess
    include Rename


  private
    # replaces the UID.
    def uid!(new_uid)
      @uid = new_uid
    end

    # Override if you want to include/exclude properties in this file metadata.
    def default_metadata_for(job)
      {:width => job.width, :height => job.height, :uid => uid, :content_type => job.mime_type, :size => job.size}
    end

    def metadata_for(job, additional={})
      default_metadata_for(job).merge(additional)
    end
  end
end