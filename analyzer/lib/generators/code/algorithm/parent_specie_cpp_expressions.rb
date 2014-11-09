module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains methods for generate cpp expressions with using parent species
        module ParentSpecieCppExpressions
        private

          # Gets code string with call getting atom from parent specie
          # @param [UniqueSpecie] parent from which will get index of twin
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   twin of which will be used for get an index of it atom from parent specie
          # @return [String] code where atom getting from parent specie
          def atom_from_parent_call(parent, twin)
            parent_var_name = namer.name_of(parent)
            twin_index = parent.index(twin)
            "#{parent_var_name}->atom(#{twin_index})"
          end
        end

      end
    end
  end
end
