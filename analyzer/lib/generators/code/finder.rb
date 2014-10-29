module VersatileDiamond
  module Generators
    module Code

      # Creates Finder class which using for find all available species (which will
      # found all correspond possible reactions) when simulation do
      class Finder < CppClassWithGen
        extend Forwardable

        # Initializes Finder class code generator also by handbook, because Finder is
        # direct user of Handbook class
        #
        # @param [EngineCode] generator see at #super same argument
        # @param [Handbook] handbook class code generator
        def initialize(generator, handbook)
          super(generator)
          @handbook = handbook
        end

      private

        def_delegators :@handbook,
          :ubiquitous_reactions_exists?, :lateral_reactions_exists?

        # Provides the list of including files
        # @return [Array] the list of files which should be included
        def including_files
          (root_species + ubiquitous_reactions).map(&:full_file_path).sort
        end

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
      end

    end
  end
end
