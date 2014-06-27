module Paperdragon
  # 2-level meta data hash for a file. Returns empty string if not found.
  # Metadata.new(nil)[:original][:width] => ""
  class Metadata
    def initialize(hash)
      @hash = hash || {}
    end

    def [](name)
      @hash[name] || {}
    end
  end
end