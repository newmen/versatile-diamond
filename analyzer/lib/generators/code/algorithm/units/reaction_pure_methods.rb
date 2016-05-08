module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides methods for reaction pure units
        module ReactionPureMethods
          include Algorithm::Units::ReactantAbstractType

          # Anchor specie should has a name
          def define!
            if species.one?
              kwargs = {
                name: Code::SpeciesReaction::ANCHOR_SPECIE_NAME,
                next_name: false
              }
              dict.make_specie_s(species.first, **kwargs)
            else
              raise 'Incorrect number of entry species'
            end
          end

          # @return [Boolean]
          def checkable?
            !all_defined?(anchored_species)
          end

          # @return [Boolean]
          def neighbour?(unit)
            anchored_species.select(&unit.species.public_method(:include?)).empty?
          end
        end

      end
    end
  end
end
