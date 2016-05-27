module VersatileDiamond
  module Organizers

    # Provides base logic for chunks
    # @abstract
    class BaseChunk

      attr_reader :targets, :links

      # Initializes internal caches of all chunks
      # @param [Set] targets of new chunk
      # @param [Hash] links of new chunk
      def initialize(targets, links)
        @targets = targets
        @links = links

        @_target_specs, @_sidepiece_specs, @_clean_links = nil
      end

      # Gets clean graph of relations between targets and sidepiece species
      # @return [Hash] the cleaned graph which contain just significant relations
      def clean_links
        @_clean_links ||= links.each_with_object({}) do |(spec_atom, rels), acc|
          spec = spec_atom.first
          new_rels = rels.reject { |(s, _), _| spec == s }
          acc[spec_atom] = new_rels unless new_rels.empty?
        end
      end

      # Gets set of target species
      # @return [Set] the set of using target species
      def target_specs
        @_target_specs ||= targets.map(&:first).to_set
      end

      # Gets set of sidepiece species
      # @return [Set] the set of using non targets species
      def sidepiece_specs
        @_sidepiece_specs ||= links.keys.map(&:first).to_set - target_specs
      end

      # Produces new chunk but with exchanged target
      # @param [Array] from the target which will be replaced
      # @param [Array] to the target to which will be replaced
      # @return [IndependentChunk] new instance with changed target
      def replace_target(from, to)
        new_targets = replace_in_targets(from, to)
        new_links = replace_in_links(from, to)
        replace_class.new(*replace_instance_args(new_targets, new_links))
      end

      # Gets list of relations between target specs and sidepiece specs
      # @return [Array] the list of relations
      def relations
        result = sidepiece_links.flat_map do |(spec, _), rels|
          rels.reject { |(s, _), _| sidepiece?(s) }.map(&:last)
        end
        result.sort_by(&:to_s)
      end

      def inspect
        "#{to_s} ##{object_id}"
      end

    private

      # Checks that passed spec belongs to sidepiece specs
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] spec
      # @return [Boolean] is one of sidepiece specs or not
      def sidepiece?(spec)
        sidepiece_specs.include?(spec)
      end

      # Gets clean links of sidepiece specs
      # @return [Array] the list of selected key-values from clean links
      def sidepiece_links
        clean_links.select { |(spec, _), _| sidepiece?(spec) }
      end

      # Gets class of new replacing target instance
      # @return [Class] of new instance
      def replace_class
        self.class
      end

      # Gets new set of targets where one of target was replaced
      # @param [Array] from the target which will be replaced
      # @param [Array] to the target to which will be replaced
      # @return [Set] the set with replacing target
      def replace_in_targets(from, to)
        if targets.include?(from) && targets.include?(to)
          targets
        elsif targets.include?(from) && !targets.include?(to)
          (targets.to_a - [from] + [to]).to_set
        else
          raise 'Wrong swapping targets'
        end
      end

      # Gets new graph of links where one of target was replaced
      # @param [Array] from the target which will be replaced
      # @param [Array] to the target to which will be replaced
      # @return [Hash] the links with replacing target
      def replace_in_links(from, to)
        if links[from] && links[to]
          exchange_targets_in_links do |sa|
            if sa == to
              from
            else
              sa == from ? to : sa
            end
          end
        elsif links[from] && !links[to]
          exchange_targets_in_links { |sa| sa == from ? to : sa }
        else
          raise 'Wrong swapping targets of links'
        end
      end

      # Exchange relations of passed targets
      # @yield [Array, Array] iterates processing spec-atom instances
      # @return [Hash] links with swapped targets
      def exchange_targets_in_links(&block)
        links.each_with_object({}) do |(spec_atom, rels), acc|
          acc[block[spec_atom]] = rels.map { |sa, r| [block[sa], r] }
        end
      end
    end

  end
end
