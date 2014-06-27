module Paperdragon
  # A physical file with a UID.
  class File
    def initialize(uid, file=nil)
      @uid  = Uid.new(uid)
      @data = file
    end

    def uid
      @uid.call
    end

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


  private
    # replaces the UID.
    def uid!(new_uid)
      @uid = Uid.new(new_uid)
    end

    attr_reader :style # we need that in #meta_data_for.

    # def uid_for(model, class_name, style)
    #   Uid.from(
    #     id: model.id,
    #     file_name: model.image_file_name, # TODO: retrieve from somewhere else.
    #     updated_at: model.image_updated_at.to_i, # TODO: retrieve from somewhere else.
    #     fingerprint: model.image_fingerprint, # TODO: retrieve from somewhere else.
    #     style: style,
    #     class_name: class_name,
    #     attachment: :images)
    # end

    # def meta_data_for(job)
    #   {style => {:width => job.width, :height => job.height, :uid => uid, :content_type => job.mime_type, :size => job.size}}
    # end


  end


   # @style    = style
   #    @category = category


   #    # ar specific shizzle:
   #    @meta_data  = Paperdragon::Metadata.new( model_with_paperclip_attachment.image_meta_data) # DISCUSS: meta data for all styles?
end