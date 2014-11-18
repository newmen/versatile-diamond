module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from reactant specie
        class ReactantUnit < SingleSpecieUnit

          # Initializes the reactant unit
          # @param [Array] args the arguments of #super method
          # @param [DependentSpecReaction] dept_reaction by which the relations between
          #   atoms will be checked
          def initialize(*args, dept_reaction)
            super(*args)
            @dept_reaction = dept_reaction
          end

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

          # Gets code line with defined anchors atoms for each neighbours operation
          # @return [String] the code line with defined achor atoms variable
          def define_nbrs_specie_anchors_lines
            define_nbrs_anchors_line
          end

          # Gets relation between first and second passed atoms
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   target_atom the atom of target specie from which relation will be checked
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   other_atom the atom of other specie to which relation will be checked
          # @return [Concepts::Bond] the relation between passed atoms
          def relation_between(target_atom, other_atom)
            target_sa = [target_specie.spec.spec, target_atom]
            @dept_reaction.relation_between_by_saa(target_sa, other_atom)
          end

          # Gets the engine framework class for reactant specie
          # @return [String] the engine framework class for reactant specie
          def specie_type
            'SpecificSpec'
          end
        end

      end
    end
  end
end
