module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Describes atoms builder variable
        class AtomsBuilderVariable < Core::Variable

          TYPE = Core::ObjectType['AtomBuilder'].freeze
          NAME = 'builder'.freeze

          class << self
            # @param [Object] instance
            # @return [This]
            def [](instance)
              super(instance, TYPE, NAME)
            end
          end

          # @param [Instances::UniqueReactant] specie which is product
          # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
          #   atom of correspond product specie
          # @return [Core::FunctionCall]
          def build(specie, atom)
            props = specie.properties_of(atom)
            actives = Core::Constant[props.unbonded_actives_num].freeze
            role = Core::Constant[specie.actual_role(atom)].freeze
            method_name = AtomBuilder.method_for(atom).freeze
            member(method_name, role, actives)
          end
        end

      end
    end
  end
end
