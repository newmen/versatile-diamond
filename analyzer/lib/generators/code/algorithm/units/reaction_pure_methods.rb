module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides methods for reaction pure units
        module ReactionPureMethods
          include Algorithm::Units::ReactantCommonMethods
          include Algorithm::Units::ReactantAbstractType

          # Anchor specie should has a name
          def define!
            if species.one?
              kwargs = {
                name: Code::Specie::TARGET_SPECIE_NAME,
                next_name: false
              }
              dict.make_specie_s(species.first, **kwargs)
            else
              raise 'Incorrect number of entry species'
            end
          end
        end

      end
    end
  end
end
