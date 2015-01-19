module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains the target symbol for where logic object
        class TargetNode

          attr_reader :lattice

          # Initializes the node object
          # @param [Symbol] target symbol of where object
          def initialize(target, lattice)
            @target = target
            @lattice = lattice
          end

          # Gets the cap (not unique specie) for algorithm detectors
          # @return [Symbol] :_uniq_specie_cap
          def uniq_specie
            :_target_node_uniq_specie_cap
          end

          # Gets the target symbol as atom
          # @return [Symbol] the target symbol
          def atom
            @target
          end

          # Gets the cap (unique properties) for algorithm detectors
          # @return [Object] unique object
          def properties
            Object.new
          end

          # Gets the cap of limits for backbone orderer
          # @return [Hash] the static hash
          def relations_limits
            lattice.instance.relations_limit
          end

          # The target node is not a typical node!
          # @return [Boolean] true
          def none?
            true
          end

          # TODO: the #scope? also should return true

          def inspect
            "(:#{@target}:)"
          end
        end

      end
    end
  end
end
