require "paperdragon/version"
require 'dragonfly'

module Paperdragon
  class MissingUploadError < RuntimeError
  end
end

require 'paperdragon/file'
require 'paperdragon/metadata'
require 'paperdragon/attachment'
require 'paperdragon/task'