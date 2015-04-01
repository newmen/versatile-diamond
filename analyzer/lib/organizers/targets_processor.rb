module VersatileDiamond
  module Organizers

    # Provides common methods for process targets of chunks
    # @depends #typical_reaction()
    # @depends #lateral_reaction()
    module TargetsProcessor
      # Makes mirror from own targets to targets from typical reaction
      # @return [Hash] the mirror from own targets to targets from typical reaction
      def mapped_targets
        return @_mapped_targets if @_mapped_targets

        get_trgs = -> reaction { reaction.each_source.to_a }
        mirror = Hash[get_trgs[lateral_reaction].zip(get_trgs[typical_reaction])]
        raise 'Wrong mapping targets' unless mirror.all? { |lt, tt| lt.same?(tt) }

        @_mapped_targets = map_targets(mirror)
      end

    private

      # Change passed mirror from "spec to spec" to "target to target"
      # @return [Hash] the targets mirror
      def map_targets(mirror)
        targets.each_with_object({}) do |target, acc|
          spec, atom = target
          tr_spec = mirror[spec]
          insec = Mcs::SpeciesComparator.make_mirror(spec, tr_spec)
          acc[target] = [tr_spec, insec[atom]]
        end
      end
    end

  end
end
