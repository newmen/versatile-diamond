module VersatileDiamond
  module Generators

    # @abstract
    class Base
    private

      def base_specs
        @base_specs ||= Tools::Chest.all(:gas_spec, :surface_spec)
      end

      def specific_specs
        @specific_specs ||= Tools::Chest.all(:specific_spec)
      end

      def termination_specs
        @termination_specs ||= Tools::Chest.all(:active_bond, :atomic_spec)
      end

      def wheres
        @wheres ||= Tools::Chest.all(:where).reduce([]) do |acc, hash|
          acc + hash.values
        end
      end

      def ubiquitous_reactions
        @ubiquitous_reactions ||= Tools::Chest.all(:ubiquitous_reaction)
      end

      def nonubiquitous_reactions
        @nonubiquitous_reactions ||= typical_reactions + lateral_reactions
      end

      def typical_reactions
        @typical_reactions ||= Tools::Chest.all(:reaction)
      end

      def lateral_reactions
        @lateral_reactions ||= Tools::Chest.all(:lateral_reaction)
      end
    end

  end
end
