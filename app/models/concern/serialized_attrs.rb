# Augments a model with dynamic generator or getter / setter
# methods for serialized attributes.
module Concern
  module SerializedAttrs
    extend ActiveSupport::Concern

    included do
      serialize :data
      serialize :previous_data
    end

    module ClassMethods
      def serialized_attr(*names)
        names.each do |name|
          define_method "#{name}=" do |v|
            self.data = {} unless self.data

            n = name.to_sym

            if self.id
              self.previous_data = {} unless self.previous_data
              self.previous_data[n] = self.data[n]
            end

            self.data[n] = v
          end

          define_method name do
            (self.data || {})[name.to_sym]
          end
        end
      end
    end
  end
end
