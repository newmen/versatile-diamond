module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # The base class for reaction algorithm builder units with many original
        # species
        # @abstract
        class BaseManyReactantsUnit < BaseUnit
          include Modules::ListsComparer
          include Mcs::SpecsAtomsComparator

          # Initializes the base unit of code builder algorithm
          # @param [EngineCode] generator the major code generator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [Hash] atoms_to_species the mirror of atoms to correspond unique
          #   species
          def initialize(generator, namer, atoms_to_species)
            super(generator, namer, atoms_to_species.keys)
            @atoms_to_species = atoms_to_species
            @target_species = @atoms_to_species.values()
            @target_concept_specs = @target_species.map(&:proxy_spec).map(&:spec)

            @_target_atom, @_symmetric_atoms = nil
          end

          # Gets unique specie for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   _ does not used
          # @return [Specie] the unique specie
          def uniq_specie_for(atom)
            @atoms_to_species[atom]
          end

          # Gets correspond original dependent spec for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the original dependent spec will be returned
          # @return [Organizers::DependentWrappedSpec] the internal dependent spec
          def dept_spec_for(atom)
            uniq_specie_for(atom).proxy_spec
          end

          # Checks that passed spec equal to any using specie
          # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          #   spec which will checked
          # @return [Boolean] is target spec or not
          def unit_spec?(spec)
            target_concept_specs.any? { |s| s == spec }
          end

          def inspect
            "BMRSU:(#{inspect_species_atoms_names}])"
          end

        private

          attr_reader :target_species, :target_concept_specs

          # JUST FOR DEBUG INSPECTATIONS
          def inspect_species_atoms_names
            strs = @atoms_to_species.map do |a, s|
              "#{inspect_name_of(s)}:#{s.inspect}·#{inspect_name_of(a)}"
            end
            strs.join('|')
          end

          # Gets the target atom
          # @return [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
          def target_atom
            return @_target_atom if @_target_atom
            pair = @atoms_to_species.max_by do |atom, specie|
              atom_properties(specie.proxy_spec, atom)
            end

            @_target_atom = pair.first
          end

          # Gets a code with for loop
          # @yield is the body of for loop
          # @return [String] the code with symmetric atoms iteration
          def each_symmetry_lambda(**, &block)
            iterator = Object.new # any unique object which was not created previously
            namer.assign_next('ae', iterator)
            i = name_of(iterator)
            num = symmetric_atoms.size

            if atoms.size == 2 && namer.full_array?(atoms)
              atoms_var_name = name_of(atoms)
              namer.reassign("#{atoms_var_name}[#{i}]", atoms.first)
              namer.reassign("#{atoms_var_name}[#{i}-1]", atoms.last)
            else
              # TODO: maybe need to redefine atoms as separated array before loop
              # statement in the case when atoms are not "full array"
              fail 'Can not figure out the next names of atoms variables'
            end

            code_line("for (int #{i} = 0; #{i} < #{num}; ++#{i})") +
              code_scope(&block)
          end

          # Gets list of pairs of atoms and corresponding atom properties
          # @return [Array] the list of pairs
          def atoms_to_props
            target_concept_specs.zip(atoms).map do |spec, atom|
              [atom, atom_properties_from_concepts(spec, atom)]
            end
          end

          # Gets list of possible symmetric atoms
          # @return [Array] the list where similar atoms presents
          def symmetric_atoms
            return @_symmetric_atoms if @_symmetric_atoms
            # TODO: Not entirely sure of the correctness of this method. It is possible
            # that need to use intersection with itself. But this method proved himself
            # no worse than the version with search symmetric atoms on intersection,
            # at all currently available tests.
            repeated = atoms_to_props.groups(&:last).select { |gr| gr.size > 1 }
            @_symmetric_atoms = repeated.flat_map { |gr| gr.map(&:first) }
          end

          # Checks that atoms of reactants are equal
          # @return [Boolean] are atoms of reactants equal or not
          def main_atoms_asymmetric?
            symmetric_atoms.any? do |atom|
              spec_atom = spec_atom_key(atom)
              symmetric_atoms.any? do |a|
                next false if atom == a
                next true unless same_sa?(spec_atom, spec_atom_key(a))

                relations =
                  [atom, a].map(&method(:clean_relations_of)).map do |rels|
                    rels.map(&:last)
                  end

                !lists_are_identical?(*relations, &:==)
              end
            end
          end

          # Gets the correct key of relations checker links for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the key will be returned
          # @return [Array] the key of relations checker links graph
          def spec_atom_key(atom)
            [dept_spec_for(atom).spec, atom]
          end
        end

      end
    end
  end
end
