module Paperdragon
  class File
    module Process
      def process!
        job = Dragonfly.app.new_job(data)

        yield job if block_given?

        puts "........................STORE  (process): #{uid}"
        job.store(path: uid, :headers => {'x-amz-acl' => 'public-read', "Content-Type" => "image/jpeg"})

        job # TODO: return meta-data?
        #meta_data_for(job) # DISCUSS: override old meta_data? TEST!
      end
    end


    module Delete
      def delete!
        puts "........................DELETE (delete): #{uid}"
        Dragonfly.app.destroy(uid)
      end
    end


    module Reprocess
      def reprocess!(original, fingerprint)
        job = Dragonfly.app.new_job(original.data) # inheritance here somehow?

        yield job if block_given?

        old_uid = uid
        uid!(fingerprint) # new UID is computed and set.

        puts "........................STORE  (reprocess): #{uid}"
        job.store(path: uid, headers: {'x-amz-acl' => 'public-read', "Content-Type" => "image/jpeg"}) # store with thumb url.

        puts "........................DELETE (reprocess): #{old_uid}"
        Dragonfly.app.destroy(old_uid)

        # @data = nil
        # meta_data_for(job) # DISCUSS: override old meta_data? TEST!
        job
      end
    end
  end
end