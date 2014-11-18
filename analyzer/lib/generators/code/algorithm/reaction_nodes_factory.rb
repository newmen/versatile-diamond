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
            @specs_cache = {}
            @specs_to_uniques = {}
          end

        private

          # Creates node for passed spec with atom
          # @return [Node] new node which contain the correspond algorithm specie and
          #   atom
          def create_node(spec_atom)
            spec, atom = spec_atom
            specie = get_unique_specie(spec)
            dept_spec = get_dept_spec(spec)
            ReactantNode.new(specie.original, specie, dept_spec, atom)
          end

          def get_dept_spec(spec)
            @specs_cache[spec] ||=
              if spec.is_a?(Concepts::SpecificSpec)
                Organizers::DependentSpecificSpec.new(spec)
              else
                Organizers::DependentBaseSpec.new(spec)
              end
          end

          # Makes unique specie instance from passed spec
          # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          #   spec by which the unique algorithm specie will be maked
          # @return [UniqueSpecie] the wrapped specie code generator
          def get_unique_specie(spec)
            return @specs_to_uniques[spec] if @specs_to_uniques[spec]
            specie = specie_class(spec)
            @specs_to_uniques[spec] = UniqueSpecie.new(specie, specie.spec)
          end
        end

      end
    end
  end
end
