module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm::Units

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
          def target_symmetries_lambda(**, &block)
            code_for_loop('uint', 'ae', symmetric_atoms.size) do |i|
              if atoms.size == 2 && namer.full_array?(atoms)
                atoms_var_name = name_of(atoms)
                namer.reassign("#{atoms_var_name}[#{i}]", atoms.first)
                namer.reassign("#{atoms_var_name}[#{i}-1]", atoms.last)
              else
                # TODO: maybe need to redefine atoms as separated array before loop
                # statement in the case when atoms are not "full array"
                raise 'Can not figure out the next names of atoms variables'
              end
              block.call
            end
          end

          # Gets list of possible symmetric atoms
          # @return [Array] the list where similar atoms presents
          def symmetric_atoms
            @_symmetric_atoms ||= best_intersection.map(&:first).map(&:last)
          end

          # Collects the links graph which contains relations between own internal
          # species
          #
          # @return [Hash] the cutten links without relations between not own specs
          def target_concepts_links
            concept_specs = target_concept_specs.uniq
            concept_specs.each_with_object({}) do |spec, acc|
              relations_checker.links.each do |spec_atom, rels|
                next unless spec == spec_atom.first
                acc[spec_atom] = rels.select { |(s, _), _| concept_specs.include?(s) }
              end
            end
          end

          # Finds self intersetions of target concepts links graphs
          # @return [Array] the list of intersections
          def self_intersections
            comparing_links = [target_concepts_links] * 2
            objs = comparing_links.map { |links| Mcs::LinksWrapper.new(links) }
            Mcs::SpeciesComparator.intersec(*objs) { |_, _, v, w| same_sa?(v, w) }
          end

          # Selects best intersection and drops all unsignificant atoms compliance
          # @return [Array] the list of symmetric spec-atom pairs
          def best_intersection
            cmp_proc = Proc.new { |v, w| v != w && atoms.include?(v.last) }
            best = self_intersections.max_by { |insec| insec.count(&cmp_proc) }
            best.select(&cmp_proc)
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
