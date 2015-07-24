require 'active_support/inflector/methods'

module VersatileDiamond
  module Patches

    # Provides additional methods for string (like as ActiveSupport)
    module RichString
      refine String do
        def pluralize
          ActiveSupport::Inflector.pluralize(self)
        end

        def underscore
          camelparts = split('::').last.scan(/[A-Z][a-z0-9]*/)
          camelparts.empty? ? self : camelparts.map(&:downcase).join('_')
        end

        def classify
          names = split('/').map { |part| part.split('_').map(&:capitalize).join }
          names.join('::')
        end

        def constantize
          VersatileDiamond.const_get(classify)
        end
      end
    end

  end
end
