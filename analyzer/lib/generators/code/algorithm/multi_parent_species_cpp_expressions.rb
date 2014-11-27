module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains methods for generate cpp expressions with using parent species
        module MultiParentSpeciesCppExpressions
        private

          # Gets parent specie and correspond twin for passed atom
          # @yield [UniqueSpecie, Atom] does for select parent and twin
          # @return [Array] the array of two items
          def parent_with_twin_for(atom, &block)
            specs_to_parents = Hash[parent_species.map { |pr| [pr.proxy_spec, pr] }]
            original_parents = original_spec.parents_with_twins_for(atom)
            pwts = original_parents.map do |proxy_parent, twin|
              [specs_to_parents[proxy_parent], twin]
            end
            pwts.find(&block)
          end
        end

      end
    end
  end
end
