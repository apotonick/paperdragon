module Paperdragon
  class Paperclip
    module Model
      def image #TODO: make name configurable
        Proxy.new(self)
      end


      # Needed to expose Paperclip's DSL, like avatar.image.url(thumb).
      class Proxy
        def initialize(model)
          @model = model
        end

        def url(style)
          @model.class.const_get("Photo").new(@model, style).url # TODO: make configurable.
        end
      end
    end
  end
end