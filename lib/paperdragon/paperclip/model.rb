module Paperdragon
  class Paperclip
    # DISCUSS: I want to remove this module.
    module Model
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def processable(name, attachment_class)
          # this overrides #image (or whatever the name is) from Paperclip::Model::processable.
          # This allows using both paperclip's `image.url(:thumb)` and the new paperdragon style
          # `image(:thumb).url`.
          mod = Module.new do # TODO: merge with attachment_accessor_for.
            define_method name do # e.g. Avatar#image
              Proxy.new(name, self, attachment_class)  # provide paperclip DSL.
            end
          end
          include mod
        end
      end


      # Needed to expose Paperclip's DSL, like avatar.image.url(:thumb).
      class Proxy
        def initialize(name, model, attachment_class)
          @attachment = attachment_class.new(model.public_send("#{name}_meta_data"), {:model => model})
        end

        def url(style)
          @attachment[style].url # Avatar::Photo.new(avatar, :thumb).url
        end

        def method_missing(name, *args, &block)
          @attachment.send(name, *args, &block)
        end
      end
    end
  end
end