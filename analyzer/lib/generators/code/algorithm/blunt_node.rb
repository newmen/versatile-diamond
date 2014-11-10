module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The intermediate vertex value of algorithm graphs which uses when cpp code
        # generates
        class BluntNode
          include Modules::OrderProvider
          extend Forwardable

          attr_reader :uniq_specie
          def_delegators :uniq_specie, :none?, :scope?

          # Initializes the node object
          # @param [Specie] original_specie which (or which atom) was plased in
          #   original analysing graph vertex
          # @param [NoneSpec | UniqueSpecie | SpeciesScope] uniq_specie which
          #   correspond to using parent species
          def initialize(original_specie, uniq_specie)
            @original_specie = original_specie
            @uniq_specie = uniq_specie
          end

          # Compares current node with another node
          # @param [Node] other comparing node
          # @yield when other node same as current
          # @return [Integer] the comparing result
          def <=> (other, &block)
            typed_order(uniq_specie, other.uniq_specie, :none?) do
              typed_order(other.uniq_specie, uniq_specie, :scope?) do
                block_given? ? block.call : 0
              end
            end
          end

          # Blunt node always is blunt
          # @return [Boolean] true
          def blunt?
            true
          end

          def inspect
            "(#{uniq_specie.inspect})"
          end
        end

      end
    end
  end
end
