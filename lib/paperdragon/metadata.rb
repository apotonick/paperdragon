module Paperdragon
  # 2-level meta data hash for a file. Returns empty string if not found.
  # Metadata.new(nil)[:original][:width] => ""
  # Holds metadata for an attachment. This is a hash keyed by versions, e.g. +:original+,
  # +:thumb+, and so on.
  class Metadata < Hash
    def self.[](hash) # allow Metadata[nil]
      super hash || {}
    end

    def [](name)
      super || {}
    end

    def populated?
      size > 0
    end

    def to_hash
      self
    end
  end
end