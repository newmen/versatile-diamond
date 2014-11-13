module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from reactant specie
        class ReactantUnit < SingleSpecieUnit
          include SpecieUnitBehavior

          # Assigns the name for internal reactant specie, that it could be used when the
          # algorithm generating
          # @override
          def first_assign!
            namer.assign(SpeciesReaction::ANCHOR_SPECIE_NAME, target_specie)
          end

          # Prepares reactant instance for reaction creation
          # @yield should get cpp code string which is body of checking
          # @return [String] the cpp code string
          def check_symmetries(&block)
            if symmetric?
              each_symmetry_lambda(&block)
            else
              block.call
            end
          end

          def inspect
            "RU:(#{inspect_specie_atoms_names}])"
          end

        private

          # Checks that internal target specie is symmetric by target atoms
          # @return [Boolean] is symmetric or not
          def symmetric?
            atoms.any? { |a| target_specie.symmetric_atom?(a) }
          end

          # Gets code string with call getting atom from target specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be used for get an index from target specie
          # @return [String] code where atom getting from target specie
          # @override
          def atom_from_specie_call(atom)
            super(target_specie, atom)
          end

          # Reactant specie doesn't need defines, it already defined by find method
          # signature
          #
          # @return [String] the empty line
          def define_target_specie_line
            ''
          end

          # Gets the engine framework class for reactant specie
          # @return [String] the engine framework class for reactant specie
          def specie_type
            'SpecificSpec'
          end

          # Gets the code string with getting the target specie from atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the target specie will be gotten
          # @return [String] cpp code string with engine framework method call
          # @override
          def spec_by_role_call(atom)
            super(atom, target_specie, atom)
          end
        end

      end
    end
  end
end
