module VersatileDiamond
  module Generators
    module Code

      # Creates Finder class which using for find all available species (which will
      # found all correspond possible reactions) when simulation do
      class Finder < CppClassWithGen
        extend Forwardable

      private

        def_delegator :generator, :handbook
        def_delegators :handbook,
          :ubiquitous_reactions_exists?, :lateral_reactions_exists?

        # Gets the sorted list of source species. Sorting is very important because
        # most small species should be found before largest species. There could be
        # used topological sort for ordering source species by dependencies between
        # them, but used order of dependent species also adequately.
        #
        # @return [Array] the sorted list of source specie code generators
        def root_species
          generator.species.select(&:find_root?).sort { |a, b| a.spec <=> b.spec }
        end

        # Gets the sorted list of ubiquitous reactions
        # @return [Array] the list of ubiquitous reaction code generators
        def ubiquitous_reactions
          []
        end

        # Provides the list of including objects
        # @return [Array] the list of objects which should be included
        def body_include_objects
          root_species + ubiquitous_reactions
        end
      end

    end
  end
end
