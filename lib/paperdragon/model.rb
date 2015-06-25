module Paperdragon
  # Fuzzy API: gives you #image that can do both upload and rendering.
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
            attachment = attachment_class.new(image_meta_data, options.merge(model: self))

            return attachment unless file or block

            # run the task block and save the returned new metadata in the model.
            self.image_meta_data = attachment.task(*[file], &block)
          end
        end
      end
    end


    #   class Album
    #     extend Paperdragon::Model::Writer
    #     processable_writer :image
    #
    # Provides Album#image!(file) { |v| v.thumb!("64x64") }
    module Writer
      def processable_writer(name, attachment_class=Attachment)
        mod = Module.new do # TODO: abstract that into Uber, we use it everywhere.
          define_method "#{name}!" do |file=nil, options={}, &block|
            attachment = attachment_class.new(image_meta_data, options.merge(model: self))

            # run the task block and save the returned new metadata in the model.
            self.image_meta_data = attachment.task(*[file], &block)
          end
        end
        include mod
      end
    end # Writer.


    #   class Album
    #     extend Paperdragon::Model::Reader
    #     processable_reader :image
    #
    # Provides Album#image #=> Attachment.
    module Reader
      def processable_reader(name, attachment_class=Attachment)
        define_method name do
          attachment_class.new(image_meta_data, model: self)
        end
      end
    end
  end
end