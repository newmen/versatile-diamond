module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates nodes for reaction algorithm graphs building
        class ReactionNodesFactory < BaseNodesFactory
          # Initizalize reaction nodes factory
          # @param [EngineCode] generator the major code generator
          def initialize(generator)
            super(generator)
            @uniques_cache = {}
          end

        private

          # Creates node for passed spec with atom
          # @return [Node] new node which contain the correspond algorithm specie and
          #   atom
          def create_node(spec_atom)
            spec, atom = spec_atom
            specie = get_unique_specie(spec)
            ReactantNode.new(specie.original, specie, atom)
          end

          # Makes unique specie instance from passed spec
          # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          #   spec by which the unique algorithm specie will be maked
          # @return [UniqueSpecie] the wrapped specie code generator
          def get_unique_specie(spec)
            return @uniques_cache[spec] if @uniques_cache[spec]
            specie = specie_class(spec)
            dept_spec = specie.spec.clone_with_replace(spec)
            @uniques_cache[spec] = UniqueSpecie.new(specie, dept_spec)
          end
        end

      end
    end
  end
end
