module VersatileDiamond
  module Concepts

    # Provides methods for mono instance property
    module MonoInstanceProperty
      class << self
        # Triggers when module included in some class
        # @param [Class] base class which includes current module
        def included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          # Gets an instance of current class
          # @return [MonoInstanceProperty] an instance of monoinstance property
          def property
            # TODO: maybe more properly to use Singleton module
            @__instance ||= new
          end
        end
      end
    end

  end
end
