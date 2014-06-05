require 'active_support/inflector'

module VersatileDiamond
  module Patches

    # Provides additional methods for string (like as ActiveSupport)
    module RichString
      refine String do
        def pluralize
          ActiveSupport::Inflector.pluralize(self)
        end

        def underscore
          split('::').last.scan(/[A-Z][a-z0-9]*/).map(&:downcase).join('_')
        end

        def classify
          names = split('/').map do |part|
            part.split('_').map(&:capitalize).join
          end
          names.join('::')
        end

        def constantize
          VersatileDiamond.const_get(classify)
        end
      end
    end

  end
end
