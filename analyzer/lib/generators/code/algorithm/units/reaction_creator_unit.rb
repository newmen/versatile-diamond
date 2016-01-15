module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The instance of class could defines all neccessary variables and calls
        # engine framework method for create a reaction which was found
        class ReactionCreatorUnit < BaseReactionCreatorUnit
          include SpecificSpecDefiner

          # Gets the code lines for reaction creation
          # @return [String] the lines by which the reaction will be created
          def lines
            if species.one?
              create_line
            else
              define_target_species_variable_line + create_line
            end
          end

        private

          # Gets the cpp code string with creation of target reaction
          # @return [String] the cpp code line with creation target reaction call
          def create_line
            code_line("create<#{reaction.class_name}>(#{name_of(species)});")
          end

          # Finds previously defined atom
          # @param [UniqueSpecie] specie see at #spec_from_atom_call same argument
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which already defined before
          def atom_of(specie)
            find_defined(specie.proxy_spec.anchors)
          end

          # Makes code which gets target specie instance from passed atom
          # @param [UniqueSpecie] specie which simulation instance will be gotten
          # @return [String] the string of cpp code with specByRole call
          def spec_from_atom_call(specie)
            atom = atom_of(specie)
            spec_by_role_call(atom, specie, atom)
          end

          # Gets the line with definition of target species array variable
          # @return [String] th ecpp code line with definition of target species var
          def define_target_species_variable_line
            items = names_or(species, &method(:spec_from_atom_call))
            namer.reassign(SpeciesReaction::ANCHOR_SPECIE_NAME, species)
            define_var_line("#{specie_type} *", species, items)
          end
        end

      end
    end
  end
end
