module Paperdragon
  class File
    module Process
      def process!
        job = Dragonfly.app.new_job(data)

        yield job if block_given?

        puts "........................STORE  (process): #{uid}"
        job.store(path: uid, :headers => {'x-amz-acl' => 'public-read', "Content-Type" => "image/jpeg"}) # store with thumb url.

        job # TODO: return meta-data?
        #meta_data_for(job) # DISCUSS: override old meta_data? TEST!
      end
    end
  end
end