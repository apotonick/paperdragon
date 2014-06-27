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
  end
end