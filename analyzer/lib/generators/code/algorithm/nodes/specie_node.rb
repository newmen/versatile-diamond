module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm::Nodes

        # Contains special logic for specie algorithms
        class SpecieNode < BaseNode

          def_delegators :uniq_specie, :none?, :scope?

          # Initializes the specie node object
          # @param [EngineCode] generator the major code generator
          # @param [Specie] orig_specie the target specie code generator instance
          # @param [NoneSpec | UniqueSpecie | SpeciesScope] uniq_specie which
          #   correspond to using parent species
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which was a vertex of original graph
          def initialize(generator, orig_specie, uniq_specie, atom)
            super(generator, uniq_specie, atom)
            @orig_specie = orig_specie
          end

          # Splits the scope node to independent nodes
          # @return [Array] the list of independent nodes
          def split
            uniq_specie.species.groups.flat_map do |parents|
              node = self.class.new(generator, @orig_specie, parents.first, atom)
              [node] * parents.size
            end
          end

          # Checks that target atom have maximal number of possible bonds
          # @return [Boolean] has atom maximal number of bonds or not
          def limited?
            !(properties.incoherent? || properties.has_free_bonds?)
          end

          # @return [Boolean]
          def different_atom_role?
            uniq_specie.source_role(atom) != uniq_specie.actual_role(atom)
          end

          # @return [Boolean]
          # @override
          def used_many_times?
            scope? ? @generator.many_times?(spec, atom) : super
          end

          # @return [Boolean]
          # @override
          def usages_num
            scope? ? @generator.usages_num(spec, atom) : super
          end

          def inspect
            ":#{super}:"
          end

        private

          # Gets dependent specie which is context for aggregation own atom properties
          # @param [Oraganizers::DependentWrappedSpec] the spec where internal atom is
          #   defined
          def context_spec
            @orig_specie.spec
          end
        end

      end
    end
  end
end
