module Paperdragon
  # 2-level meta data hash for a file. Returns empty string if not found.
  # Metadata.new(nil)[:original][:width] => ""
  # Holds metadata for an attachment. This is a hash keyed by versions, e.g. +:original+,
  # +:thumb+, and so on.
  class Metadata
    def initialize(hash)
      @hash = hash || {}
    end

    def [](name)
      @hash[name] || {}
    end

    def populated?
      @hash.size > 0
    end

    def merge!(hash)
      @hash.merge!(hash)
    end

    def dup
      self.class.new(@hash.dup)
    end

    def to_hash
      @hash
    end
  end
end