# Augments a model with dynamic generator or getter / setter
# methods for serialized attributes.
module Concern
  module SerializedAttrs
    extend ActiveSupport::Concern

    included do
      serialize :data
    end

    module ClassMethods
      def serialized_attr(*names)
        names.each do |name|
          define_method "#{name}=" do |v|
            self.data = {} unless self.data
            self.data[name.to_sym] = v
          end

          define_method name do
            (self.data || {})[name.to_sym]
          end
        end
      end
    end
  end
end
