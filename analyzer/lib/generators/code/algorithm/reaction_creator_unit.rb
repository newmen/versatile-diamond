module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The instance of class could defines all neccessary variables and calls
        # engine framework method for create a reaction which was found
        class ReactionCreatorUnit < BaseCreatorUnit

          # Gets the code lines for reaction creation
          # @return [String] the lines by which the reaction will be created
          def lines
            if target_species.size == 1
              create_line
            else
              define_target_species_variable_line + create_line
            end
          end

        private

          alias :reaction :original_target
          alias :target_species :defined_species

          # Gets the cpp code string with creation of target reaction
          # @return [String] the cpp code line with creation target reaction call
          def create_line
            species_var_name = namer.name_of(target_species)
            code_line("create<#{reaction.class_name}>(#{species_var_name});")
          end

          # Finds previously defined atom
          # @param [UniqueSpecie] specie for which atom will be found
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which already defined before
          def atom_of(specie)
            specie.spec.anchors.find { |a| namer.name_of(a) }
          end

          # Makes code which gets target specie instance from passed atom
          # @param [UniqueSpecie] specie which simulation instance will be gotten
          # @return [String] the string of cpp code with specByRole call
          # @override
          def spec_by_role_call(specie)
            atom = atom_of(specie)
            super(atom, specie, atom)
          end

          # Gets the line with definition of target species array variable
          # @return [String] th ecpp code line with definition of target species var
          def define_target_species_variable_line
            items = target_species.map do |specie|
              namer.name_of(specie) || spec_by_role_call(specie)
            end

            namer.reassign('target', target_species)
            define_var_line('SpecificSpec *', target_species, items)
          end
        end

      end
    end
  end
end
