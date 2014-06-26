module Paperdragon
  class Paperclip
    module Model
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def processable(name, file_class)
          define_method name do # e.g. Avatar#image
            Proxy.new(self, file_class)
          end
        end
      end


      # Needed to expose Paperclip's DSL, like avatar.image.url(thumb).
      class Proxy
        def initialize(model, file_class)
          @model      = model
          @file_class = file_class
        end

        def url(style)
          @file_class.new(@model, style).url # Avatar::Photo.new(avatar, :thumb).url
        end
      end
    end
  end
end