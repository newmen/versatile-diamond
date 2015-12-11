module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains methods for generate cpp expressions with using parent species
        module MultiParentSpeciesCppExpressions
        private

          # Gets parent specie and correspond twin for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which parent specs with twins will be found
          # @option [Boolean] :anchored the flag which says that each twin atom in
          #   correspond parent specie should be an anchor
          # @yield [UniqueSpecie, Atom] does for select parent and twin
          # @return [Array] the array of two items
          def parent_with_twin_for(atom, anchored: false, &block)
            specs_to_parents = Hash[parent_species.map { |pr| [pr.proxy_spec, pr] }]
            pwts = original_spec.parents_with_twins_for(atom, anchored: anchored)
            result = pwts.map { |proxy, twin| [specs_to_parents[proxy], twin] }
            block_given? ? result.find(&block) : result.first
          end
        end

      end
    end
  end
end
