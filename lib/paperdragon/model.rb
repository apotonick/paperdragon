module Paperdragon
  module Model
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def processable(name, attachment_class)
        include attachment_accessor_for(name, attachment_class)
      end

    private
      # Creates Avatar#image that returns a Paperdragon::File instance.
      def attachment_accessor_for(name, attachment_class)
        Module.new do # TODO: abstract that into Uber, we use it everywhere.
          define_method name do
            # TODO: make sure image_meta_data is a hash!
            attachment_class.new(self)
          end
        end
      end
    end
  end
end