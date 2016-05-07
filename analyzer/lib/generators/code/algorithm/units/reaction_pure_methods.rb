module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides methods for reaction pure units
        module ReactionPureMethods
          include Algorithm::Units::ReactantAbstractType

          # @return [Boolean]
          # TODO: rspec required
          def checkable?
            !all_defined?(anchored_species)
          end

          # @return [Boolean]
          # TODO: rspec required
          def neighbour?(unit)
            anchored_species.select(&unit.species.public_method(:include?)).empty?
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          # TODO: rspec required
          def check_different_atoms_roles(&block)
            check_atoms_roles(nodes.map(&:atom), &block)
          end
        end

      end
    end
  end
end
