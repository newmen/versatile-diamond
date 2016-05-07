module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides methods for reaction pure units
        module ReactionPureMethods
          include Algorithm::Units::ReactantAbstractType

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
