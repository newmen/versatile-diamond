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
          # @param [UniqueSpeciesCacher] scache over which the unique parent
          #   species will be collected
          # @param [Specie] orig_specie the target specie code generator instance
          # @param [NoneSpec | UniqueSpecie | SpeciesScope] uniq_specie which
          #   correspond to using parent species
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which was a vertex of original graph
          def initialize(generator, scache, orig_specie, uniq_specie, atom)
            super(generator, uniq_specie, atom)
            @scache = scache
            @orig_specie = orig_specie
          end

          # Splits the scope node to independent nodes
          # @return [Array] the list of independent nodes
          def split
            if none?
              [self]
            elsif scope?
              extract
            else
              multiply
            end
          end

          # @return [Boolean]
          def splittable?
            split != [self]
          end

          # Checks that target atom have maximal number of possible bonds
          # @return [Boolean] has atom maximal number of bonds or not
          def limited?
            !(properties.incoherent? || properties.has_free_bonds?)
          end

          # @return [Boolean]
          def different_atom_role?
            properties != sub_properties
          end

          # @return [Boolean]
          # @override
          def used_many_times?
            scope? ? generator.many_times?(spec, atom) : super
          end

          # @return [Boolean]
          # @override
          def usages_num
            scope? ? generator.usages_num(spec, atom) : super
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

          # @return [Array]
          def extract
            uniq_specie.species.groups.flat_map do |parents|
              [bro(parents.first)] * parents.size
            end
          end

          # @return [Array]
          def multiply
            context_spec.parents_of(atom).map do |spec|
              if spec == context_spec
                self
              else
                bro(@scache.get_unique_specie(spec))
              end
            end
          end

          # @param [SpecieInstance] parent
          # @return [SpecieNode]
          def bro(parent)
            self.class.new(generator, @scache, @orig_specie, parent, atom)
          end
        end

      end
    end
  end
end
