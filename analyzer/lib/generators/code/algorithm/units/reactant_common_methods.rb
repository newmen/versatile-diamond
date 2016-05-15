module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides common methods for reactant pure units
        module ReactantCommonMethods
          include Algorithm::Units::ReactantAbstractType

          # @param [BasePureUnit] unit
          # @return [Boolean]
          def neighbour?(unit)
            anchored_species.select(&unit.species.public_method(:include?)).empty?
          end

          def inspect
            sis = species.map(&:inspect)
            nas = nodes.uniq(&:atom)
            spops = nas.map(&:sub_properties).map(&:inspect)
            pkns = nas.map do |n|
              n.spec.spec.keyname(n.uniq_specie.send(:reflection_of, n.atom))
            end
            pkwps = pkns.zip(spops).map { |kp| kp.join(':') }
            "•[#{sis.join(' ')}] [#{pkwps.join(' ')}]•"
          end
        end

      end
    end
  end
end
