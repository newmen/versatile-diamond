module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code for non root specie that depends from one parent specie
        class SingleParentNonRootSpecieUnit < SingleParentRootSpecieUnit

          # Assigns the name for internal parent specie, that it could be used when the
          # algorithm generating
          # @override
          def first_assign!
            namer.assign(Specie::ANCHOR_SPECIE_NAME, parent_specie)
          end

          # Also checks that internal parent specie is symmetric and if it is truth
          # then wraps the calling of super method to each symmetry lambda method of
          # engine framework
          #
          # @return [String] the string with cpp code which check existence of current
          #   unit, when simulation do
          # @override
          def check_existence(*)
            check_symmetries_if_need { super }
          end

          def inspect
            "SPNRSU:(#{inspect_specie_atoms_names}])"
          end

        private

          # Gets the code line with definition of anchor atom variables
          # @return [String] the definition anchor atom variables code
          # @override
          def define_anchor_atoms_line
            assign_anchor_atoms_name!
            values = atoms.map(&method(:atom_from_own_specie_call))
            define_var_line('Atom *', atoms, values)
          end
        end

      end
    end
  end
end
