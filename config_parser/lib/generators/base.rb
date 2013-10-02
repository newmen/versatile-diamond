module VersatileDiamond
  module Generators

    class Base
    private

      include Tools::Handbook

      set(:base_specs) do
        Tools::Chest.all(:gas_spec, :surface_spec)
      end

      set(:specific_specs) do
        Tools::Chest.all(:specific_spec)
      end

      set(:termination_specs) do
        Tools::Chest.all(:active_bond, :atomic_spec)
      end

      set(:wheres) do
        Tools::Chest.all(:where).reduce([]) do |acc, hash|
          acc + hash.values
        end
      end

      set(:ubiquitous_reactions) do
        Tools::Chest.all(:ubiquitous_reaction)
      end

      set(:typical_reactions) do
        Tools::Chest.all(:reaction)
      end

      set(:lateral_reactions) do
        Tools::Chest.all(:lateral_reaction)
      end
    end

  end
end
