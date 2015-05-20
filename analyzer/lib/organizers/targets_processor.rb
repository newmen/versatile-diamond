module VersatileDiamond
  using Patches::RichArray

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
        mirror = Hash[zip(get_trgs[lateral_reaction], get_trgs[typical_reaction])]
        @_mapped_targets = map_targets(mirror)
      end

    private

      # Zips two sequece so that each result pair will contain similar items
      # @param [Array] list1 the first zipping list
      # @param [Array] list2 the second zipping list
      # @return [Array] the array with pairs of similar items
      def zip(list1, list2)
        list2 = list2.dup
        list1.map do |item1|
          item2 = list2.delete_one { |x| item1.same?(x) }
          raise 'Wrong mapping targets' unless item2
          [item1, item2]
        end
      end

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
