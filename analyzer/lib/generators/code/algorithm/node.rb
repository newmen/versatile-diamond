module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The AST node for generation cpp code
        class Node
          include Modules::OrderProvider
          extend Forwardable

          attr_reader :original_specie, :uniq_specie, :atom
          def_delegators :uniq_specie, :none?, :scope?

          def initialize(original_specie, uniq_specie, atom)
            @original_specie = original_specie
            @uniq_specie = uniq_specie
            @atom = atom
          end

          def <=> (other)
            typed_order(uniq_specie, other.uniq_specie, :none?) do
              typed_order(other.uniq_specie, uniq_specie, :scope?) do
                order(other, self, :properties) do
                  other.original_specie.spec <=> original_specie.spec
                end
              end
            end
          end

          def properties
            Organizers::AtomProperties.new(@original_specie.spec, @atom)
          end

          def inspect
            "(#{@uniq_specie.inspect} | #{properties.to_s})"
          end
        end

      end
    end
  end
end
