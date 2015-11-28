module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The instance of class could defines all neccessary variables and calls
        # engine framework method for create a reaction which was found
        class ReactionCreatorUnit < BaseReactionCreatorUnit
          include SpecificSpecDefiner

          # Gets the code lines for reaction creation
          # @return [String] the lines by which the reaction will be created
          def lines
            if species.size == 1
              create_line
            else
              define_target_species_variable_line + create_line
            end
          end

        private

          # Gets the cpp code string with creation of target reaction
          # @return [String] the cpp code line with creation target reaction call
          def create_line
            code_line("create<#{@reaction.class_name}>(#{namer.name_of(species)});")
          end

          # Finds previously defined atom
          # @param [UniqueSpecie] specie see at #spec_by_role_call same argument
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which already defined before
          def atom_of(specie)
            specie.proxy_spec.anchors.find { |a| namer.name_of(a) }
          end

          # Makes code which gets target specie instance from passed atom
          # @param [UniqueSpecie] specie which simulation instance will be gotten
          # @return [String] the string of cpp code with specByRole call
          def spec_by_role_call(specie)
            atom = atom_of(specie)
            super(atom, specie, atom)
          end

          # Gets the line with definition of target species array variable
          # @return [String] th ecpp code line with definition of target species var
          def define_target_species_variable_line
            items = species.map { |s| namer.name_of(s) || spec_by_role_call(s) }
            namer.reassign(SpeciesReaction::ANCHOR_SPECIE_NAME, species)
            define_var_line("#{specie_type} *", species, items)
          end
        end

      end
    end
  end
end
