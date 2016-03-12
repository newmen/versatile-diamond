module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code from one node
        class PureMonoUnit < BaseUnit

          # @param [NameRemember] namer
          # @param [Nodes::SpecieNode] node
          def initialize(namer, node)
            super(namer, [node])
          end

          # Anytime is a previous found specie
          # @param [VarsDictionary] context
          def entry_point!(context)
            if species.one?
              parent = species.first
              var = one_specie_variable(parent, name: Code::Specie::ANCHOR_SPECIE_NAME)
              context.retain_var!(parent, var)
            else
              raise 'Incorrect number of entry species'
            end
          end
        end

      end
    end
  end
end
