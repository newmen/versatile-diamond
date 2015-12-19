module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        # Contains special logic for specie algorithms
        class SpecieNode < BaseNode

          def_delegators :uniq_specie, :none?, :scope?

          # Checks that target atom have maximal number of possible bonds
          # @return [Boolean] has atom maximal number of bonds or not
          def limited?
            !(properties.incoherent? || properties.has_free_bonds?)
          end

          def inspect
            ":#{super}:"
          end

        private

          # Gets dependent specie which is context for aggregation own atom properties
          # @param [Oraganizers::DependentWrappedSpec] the spec where internal atom is
          #   defined
          def atom_properties_context
            orig_specie.spec
          end
        end

      end
    end
  end
end
