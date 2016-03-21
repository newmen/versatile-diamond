module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates nodes for specie algorithm graphs building
        class SpecieNodesFactory < BaseNodesFactory
          include SpeciesUser

          # Initizalize specie nodes factory
          # @param [EngineCode] generator the major code generator
          # @param [Specie] specie for which the nodes will be gotten
          def initialize(generator, specie)
            super(generator)
            @specie = specie

            @_none_specie = nil
          end

        private

          # Detects correct unique parent specie by passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which the unique parent specie will be got
          # @return [Instances::NoneSpecie | Instances::UniqueSpecie |
          #           Instances::SpeciesScope] the correspond unique parent specie
          def parent_specie(atom)
            parents = collect_parents(atom)
            if parents.empty?
              get_none_specie
            elsif parents.one?
              get_unique_specie(parents.first)
            else
              get_species_scope(parents, atom)
            end
          end

          # Gets the instance of none specie
          # @return [Instances::NoneSpecie] the specie instance without parents
          def get_none_specie
            @_none_specie ||= Instances::NoneSpecie.new(generator, @specie)
          end

          # Gets the scope of species for passed atom
          # @param [Array] parents which available in context specie from passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which the species scope will be got
          # @return [Instances::SpeciesScope] the scope of species
          def get_species_scope(parents, atom)
            unique_parents = parents.map(&method(:get_unique_specie))
            Instances::SpeciesScope.new(@specie, unique_parents)
          end

          # Gets the class of creating unique instance
          # @return [Class] the class of unique parent specie which instnace will be
          #   stored in new node
          def instance_class
            Instances::UniqueParent
          end

          # Creates node for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which the new node will be created
          # @return [Nodes::SpecieNode] new node which contain the correspond algorithm
          #   specie and passed atom
          def create_node(atom)
            Nodes::SpecieNode.new(generator, @specie, parent_specie(atom), atom)
          end

          # Gets list of parent species which can be checked by passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which the parent species will be collected
          # @return [Array] the actual list of parent species
          def collect_parents(atom)
            spec = @specie.spec
            anchored_parents = spec.parents_of(atom, anchored: spec.complex?)
            anchored_parents.empty? ? spec.parents_of(atom) : anchored_parents
          end
        end

      end
    end
  end
end
