module VersatileDiamond
  module Generators
    module Code

      # Provides useful methods for specie analysing
      module SymmetryHelper
      protected

        # Gets the all atoms of internal specie
        # @return [Array] the array of atoms
        def atoms
          spec.links.keys
        end

      private

        # Wraps dependent spec to atom sequence instance
        # @param [Organizers::DependentWrappedSpec] spec which will be wrapped
        # @return [AtomSequence] the instance with passed specie
        def get(spec)
          cacher.get(spec)
        end
      end

    end
  end
end
