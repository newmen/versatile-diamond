module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Contains methods for generate cpp expressions with using specie instances
        module SpecieCppExpressions
        private

          # Gets code string with call getting atom from specie
          # @param [UniqueSpecie] specie from which will get index of twin
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom of which will be used for get an index of it from specie
          # @return [String] code where atom getting from specie
          def atom_from_specie_call(specie, atom)
            index = specie.index(atom)
            unless index
              raise ArgumentError, "Undefined atom #{atom} for #{specie.original}"
            end
            "#{name_of(specie)}->atom(#{index})"
          end
        end

      end
    end
  end
end
