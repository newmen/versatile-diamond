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
            !all_defined?(species)
          end

          # @return [Boolean]
          def neighbour?(unit)
            species.select(&unit.species.public_method(:include?)).empty?
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
