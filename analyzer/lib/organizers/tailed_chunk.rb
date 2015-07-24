module VersatileDiamond
  module Organizers

    # Provides method which combine tail name for chunk
    module TailedChunk
      include Modules::SpecNameConverter

      # Collecs all names from sidepiece species and joins it by 'and' string
      # @return [String] the combined name by names of there objects
      def tail_name
        return @_tail_name if @_tail_name

        names = sidepiece_specs.map(&:name).map do |name|
          convert_name(name, :underscore, '-')
        end

        @_tail_name = names.sort.join(' and ')
      end
    end

  end
end
