module VersatileDiamond
  module Generators
    module Code

      # Stand guard that checks using source gas of reaction
      module ReactionWithSimpleGas
      private

        # Gets gas specie which using in reaction
        # @return [Array] the list of specs from gas phase
        # @override
        def gas_specs
          source_gases = reaction.simple_source
          if source_gases.empty? || source_gases.size > 1
            raise 'Wrong number of source gases for ubiquitous reaction'
          end

          spec = source_gases.first
          unless spec.gas? && spec.simple?
            raise 'Simple source specie is not simple gas'
          end

          unless spec.links.keys.first.name == :H
            raise 'Current version of Versatile Diamond does not support the ubiquitous reactions with simple gas which is not hydrogen'
          end

          source_gases
        end
      end

    end
  end
end
