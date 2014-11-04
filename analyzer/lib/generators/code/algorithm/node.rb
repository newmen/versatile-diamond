module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The AST node for generation cpp code
        class Node

          attr_reader :uniq_specie, :atom

          def initialize(original_specie, uniq_specie, atom)
            @original_specie = original_specie
            @uniq_specie = uniq_specie
            @atom = atom
          end

          def properties
            Organizers::AtomProperties.new(@original_specie.spec, @atom)
          end

          def inspect
            "(#{@uniq_specie.inspect}, #{properties.to_s})"
          end
        end

      end
    end
  end
end
