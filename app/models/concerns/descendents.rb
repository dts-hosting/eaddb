module Descendents
  extend ActiveSupport::Concern

  module ClassMethods
    def available_types
      descendants_with_names
        .sort_by { |_, display_name| display_name }
        .map { |klass, name| [name, klass] }
    end

    def descendants_with_names
      Rails.application.eager_load! if Rails.env.development?
      descendants = ObjectSpace.each_object(Class).select { |klass| klass < self }

      descendants.map do |klass|
        [klass.to_s, klass.display_name]
      end
    end

    def descendants_including_self
      Rails.application.eager_load! if Rails.env.development?
      ObjectSpace.each_object(Class).select { |klass| klass <= self }
    end
  end
end
