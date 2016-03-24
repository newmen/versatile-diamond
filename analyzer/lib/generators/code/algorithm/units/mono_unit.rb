module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code from one node
        class MonoUnit < BaseUnit
          # @param [Expressions::VarsDictionary] dict
          # @param [Nodes::SpecieNode] node
          def initialize(dict, node)
            super(dict, [node])
          end

          # Anytime is a previous found specie
          # TODO: specie specific (rspec already have)
          def define!
            parent = species.first
            kwargs = { name: Code::Specie::ANCHOR_SPECIE_NAME, next_name: false }
            dict.make_specie_s(parent, **kwargs)
          end

          # @return [Array]
          def units
            [self]
          end

          # @return [Array]
          def filled_inner_units
            specie_var = dict.var_of(species)
            atom_var = dict.var_of(atoms)
            if (specie_var && atom_var) || !(specie_var || atom_var)
              []
            else
              [self]
            end
          end
        end

      end
    end
  end
end
