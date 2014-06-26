require 'paperdragon/model'

module Paperdragon
  class Paperclip
    module Model
      def self.included(base)
        base.send :include, Paperdragon::Model
        base.extend ClassMethods
      end

      module ClassMethods
        def processable(name, file_class)
          super # defines #image(style)

          # this overrides #image (or whatever the name is) from Paperclip::Model::processable.
          # This allows using both paperclip's `image.url(:thumb)` and the new paperdragon style
          # `image(:thumb).url`.
          mod = Module.new do
            define_method name do |style=nil| # e.g. Avatar#image
              return super(style) if style # invoke paperdragon #image.
              Proxy.new(self, file_class)  # provide paperclip DSL.
            end
          end
          include mod
        end
      end


      # Needed to expose Paperclip's DSL, like avatar.image.url(:thumb).
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