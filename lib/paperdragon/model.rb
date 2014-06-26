module Paperdragon
  module Model
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def processable(name, file_class)
        include file_accessor_for(name, file_class)
      end

    private
      # Creates Avatar#image that returns a Paperdragon::File instance.
      def file_accessor_for(name, file_class)
        mod = Module.new do # TODO: abstract that into Uber, we use it everywhere.
          define_method name do |style|
            file_class.new(self, style)
          end
        end
      end
    end
  end
end