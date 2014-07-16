module Paperdragon
  # 2-level meta data hash for a file. Returns empty string if not found.
  # Metadata.new(nil)[:original][:width] => ""
  class Metadata
    def initialize(hash)
      puts "****!!! Metadata #{object_id} created at #{Time.new} with #{hash.size}"
      @hash = hash || {}

      ObjectSpace.define_finalizer(self,
                                   self.class.method(:finalize).to_proc)
    end

    def [](name)
      @hash[name] || {}
    end

    def Metadata.finalize(id)
        puts "~~~~~~~ Metadata #{id} dying at #{Time.new}"
    end
  end
end