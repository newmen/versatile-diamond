module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        # Contains special logic for specie algorithms
        class SpecieNode < BaseNode

          def_delegators :uniq_specie, :none?, :scope?

          # Checks that target atom is anchor in parent specie
          # @return [Boolean] is anchor or not
          def anchor?
            !dept_spec.parents_of(atom, anchored: true).empty?
          end

          # Checks that target atom have maximal number of possible bonds
          # @return [Boolean] has atom maximal number of bonds or not
          def limited?
            !(properties.incoherent? || properties.has_free_bonds?)
          end

          def inspect
            "*#{super}*"
          end

        private

          # Gets correct dependent specie
          # @return [Organizers::DependentWrappedSpec]
          def dept_spec
            original_specie.spec
          end

          # Provides default comparing core for the case when atom properties are equal
          # @param [SpecieNode] other comparing node
          # @return [Integer] the comparing result
          def comparing_core(other)
            typed_order(other, self, :scope?) do
              typed_order(self, other, :none?)
            end
          end
        end

      end
    end
  end
end
