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
          # @return [ActiveBond] an active bond instance
          def property
            # TODO: maybe more properly to use Singleton module
            @__instance ||= new
          end
        end
      end

      # Compares other instance with current
      # @param [TerminationSpec | SpecificSpec] other object with which comparation
      #   will be complete
      # @return [Boolean] is other a instance of same class or not
      def == (other)
        self.class == other.class
      end
    end

  end
end
