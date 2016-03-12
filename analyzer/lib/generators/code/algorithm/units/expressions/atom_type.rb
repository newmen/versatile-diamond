module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Represents atom type statement
        class AtomType < Core::ObjectType
          class << self
            def []
              super('Atom')
            end
          end
        end

      end
    end
  end
end
