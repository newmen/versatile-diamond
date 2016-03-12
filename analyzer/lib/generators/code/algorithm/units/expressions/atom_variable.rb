module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Represents atom variable statement
        class AtomVariable < Core::Variable

          DEFAULT_NAME = Code::Specie::INTER_ATOM_NAME

          class << self
            # @param [NameRemember] namer
            # @param [Object] instance
            # @param [Core::Expression] value
            # @option [String] :name
            # @return [AtomVariable]
            def [](namer, instance, value = nil, name: DEFAULT_NAME)
              super(namer, instance, AtomType[].ptr, name, value)
            end
          end

          # @param [Array] species
          # @return [Core::Condition]
          def check_roles_in(species, body)
            Core::Condition[role_in(species.first), body]
          end

          # @param [Instances::SpecieInstance] specie
          # @return [Core::OpCall]
          def role_in(specie)
            if specie.anchor?(instance)
              role = specie.actual_role(instance)
              call('is', Constant[role])
            else
              raise ArgumentError, "#{code} is not anchor of #{specie}"
            end
          end
        end

      end
    end
  end
end
