module Paperdragon
  module Model
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def processable(name, attachment_class=Attachment)
        include attachment_accessor_for(name, attachment_class)
      end

    private
      # Creates Avatar#image that returns a Paperdragon::File instance.
      def attachment_accessor_for(name, attachment_class)
        mod = Module.new do # TODO: abstract that into Uber, we use it everywhere.
          define_method name do |file=nil, options={}, &block|
            attachment = attachment_class.new(self.image_meta_data, options.merge({:model => self}))

            return attachment unless file or block

            # run the task block and save the returned new metadata in the model.
            self.image_meta_data = attachment.task(*[file], &block)
          end
        end
      end
    end
  end
end