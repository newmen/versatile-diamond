module VersatileDiamond
  module Organizers

    # Provides method which combine tail name for chunk
    module TailedChunk
      include Modules::SpecNameConverter

      # Collecs all names from sidepiece species and joins it by 'and' string
      # @return [String] the combined name by names of there objects
      def tail_name
        @_tail_name ||= tail_parts.sort.join(' and ')
      end

    private

      # Gets a list of string each of one is the part of tail name
      # @return [Array] the list of unjoined string parts
      def tail_parts
        sidepiece_specs.map do |spec|
          relations_str(spec) + convert_name(spec.name, :underscore, '_')
        end
      end

      # Gets string with relations which uses passed spec
      # @param [Concepts::Spec | Concepts::SidepieceSpec | Concepts::VeiledSpec]
      #   sidepiece_spec which relations will be collected
      # @return [String] the list of using relations separated by space with space at
      #   end of string
      def relations_str(sidepiece_spec)
        target_relations_of(sidepiece_spec).reduce('') do |acc, relation|
          acc << relation.to_s.gsub(/[\$:-]/, ' ').strip << ' '
        end
      end

      # Collects relations of passed sidepiece spec to any target specs
      # @param [Concepts::Spec | Concepts::SidepieceSpec | Concepts::VeiledSpec]
      #   sidepiece_spec which relations will be collected
      # @return [Array] the list of using relations
      def target_relations_of(sidepiece_spec)
        clean_links_of(sidepiece_spec).reduce([]) do |acc, ((spec, _), rels)|
          rels.reduce(acc) do |a, ((s, _), r)|
            target_specs.include?(s) && !a.include?(r) ? (a << r) : a
          end
        end
      end

      # Gets clean links of passed spec
      # @param [Concepts::Spec | Concepts::SidepieceSpec | Concepts::VeiledSpec]
      #   sidepiece_spec which relations will be collected
      # @return [Array] the list of clean relations
      def clean_links_of(sidepiece_spec)
        clean_links.select { |(spec, _), _| spec == sidepiece_spec }
      end
    end

  end
end
