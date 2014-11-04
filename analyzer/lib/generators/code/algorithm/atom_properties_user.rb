module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides method for getting atom properties from atoms
        module AtomPropertiesUser
        private

          # Makes list of atom properties from passed atoms list
          # @param [Array] atoms each of which will be converted to atom property
          # @return [Array] the array of atom properties
          def aps_from(*atoms)
            atoms.map { |a| Organizers::AtomProperties.new(spec, a) }
          end
        end

      end
    end
  end
end
