module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates nodes for specie algorithm graphs building
        class SpecieNodesFactory < BaseNodesFactory
          # Initizalize specie nodes factory
          # @param [EngineCode] generator the major code generator
          # @param [Specie] specie for which the nodes will be gotten
          def initialize(generator, specie)
            super(generator)
            @specie = specie
            @parents_to_uniques = {}
          end

        private

          # Creates node for passed atom
          # @return [Node] new node which contain the correspond algorithm specie and
          #   passed atom
          def create_node(atom)
            Node.new(@specie, parent_specie(atom), atom)
          end

          # Detects correct unique parent specie by passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which the unique parent specie will be got
          # @return [NoneSpecie | UniqueSpecie | SpeciesScope] the correspond unique
          #   parent specie
          def parent_specie(atom)
            parents = @specie.spec.parents_of(atom)
            if parents.empty?
              NoneSpecie.new(@specie)
            elsif parents.size == 1
              get_unique_specie(parents.first)
            else
              SpeciesScope.new(parents.map(&method(:get_unique_specie)))
            end
          end

          # Makes unique specie instance from passed spec
          # @param [Organizers::ProxyParentSpec] parent by which the unique algorithm
          #   specie will be maked
          # @return [UniqueSpecie] the wrapped passed specie code generator
          def get_unique_specie(parent)
            @parents_to_uniques[parent] ||=
              UniqueSpecie.new(specie_class(parent), parent)
          end
        end

      end
    end
  end
end
