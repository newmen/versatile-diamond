module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Contains methods for generate cpp expressions with using parent species
        module MultiParentSpeciesCppExpressions
        private

          # Gets list of parent species and correspond twins for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which parent specs with twins will be found
          # @return [Array] the list of parent species and twin atoms
          def parents_with_twins_of(atom, **kwargs)
            specs_to_parents = Hash[parent_species.map { |pr| [pr.proxy_spec, pr] }]
            pwts = original_spec.parents_with_twins_for(atom, **kwargs)
            pwts.map { |proxy, twin| [specs_to_parents[proxy], twin] }
          end

          # Gets parent specie and correspond twin for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which parent specs with twins will be found
          # @yield [UniqueSpecie, Atom] does for select parent and twin
          # @return [Array] the array of two items
          def parent_with_twin_for(atom, **kwargs, &block)
            pwts = parents_with_twins_of(atom, **kwargs, &block)
            block_given? ? pwts.find(&block) : pwts.first
          end
        end

      end
    end
  end
end
