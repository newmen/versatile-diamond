module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code from one node
        class PureMonoUnit < BaseUnit

          # @param [Expressions::VarsDictionary] dict
          # @param [Nodes::SpecieNode] node
          def initialize(dict, node)
            super(dict, [node])
          end

          # Anytime is a previous found specie
          def entry_point!
            if species.one?
              parent = species.first
              dict.make_specie_s(parent, name: Code::Specie::ANCHOR_SPECIE_NAME)
            else
              raise 'Incorrect number of entry species'
            end
          end
        end

      end
    end
  end
end
