module VersatileDiamond

  module Patches

    module RichString
      refine String do
        def underscore
          scan(/[A-Z][a-z0-9]*/).map(&:downcase).join('_')
        end

        def classify
          split('_').map(&:capitalize).join
        end

        def constantize
          VersatileDiamond.const_get(classify)
        end
      end
    end

  end

end
