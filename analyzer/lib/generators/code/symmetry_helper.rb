module VersatileDiamond
  module Generators
    module Code

      # Provides useful methods for specie analysing
      module SymmetryHelper
      protected

        # Gets anchors of internal specie
        # @return [Array] the array of anchor atoms
        def anchors
          spec.target.links.keys
        end

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

        # Gets sorted parents of target specie
        # @return [Array] the sorted array of parent seqeucnes
        def sorted_parents
          # TODO: same as in FindAlgorithmBuilder#parents
          spec.parents.sort_by { |p| -p.relations_num }
        end
      end

    end
  end
end
