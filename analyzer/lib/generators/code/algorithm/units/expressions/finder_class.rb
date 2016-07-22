module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Represents Finder class statement
        class FinderClass < Core::ObjectType

          NAME = 'Finder'.freeze

          class << self
            # @param [Object] name
            # @return [FinderClass]
            def []
              super(NAME)
            end
          end

          # @param [Core::Variable] var
          # @return [OpNs]
          def find_all(var)
            num = var.collection? ? var.items.size : 1
            fixed_var = (num == 1 ? Core::OpRef[var] : var)
            call('findAll', fixed_var, Core::Constant[num])
          end
        end

      end
    end
  end
end
