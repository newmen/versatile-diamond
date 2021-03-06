module VersatileDiamond
  module Generators
    module Code

      # Contains logic for description of common graph of all possible chunks of some
      # typical reaction
      class LateralChunks
        include Modules::ListsComparer
        include Modules::RelationBetweenChecker
        include ReactionsUser
        extend Forwardable

        attr_reader :reaction
        def_delegators :total_chunk, :clean_links, :target_specs
        def_delegators :overall_chunk, :targets, :sidepiece_specs

        # Initializes meta object which provides useful methods for code generators
        # @param [EngineCode] generator of engine code
        # @param [TypicalReaction] typical_reaction from which the chunks of children
        #   lateral reactions will be wrapped
        # @param [Array] lateral_reactions the children reactions of passed typical
        def initialize(generator, typical_reaction, lateral_reactions)
          @generator = generator
          @reaction = typical_reaction
          @affixes = lateral_reactions.sort_by(&:chunk)

          @all_chunks = lateral_reactions.map(&:chunk)
          @root_chunks = lateral_reactions.flat_map(&:internal_chunks).uniq

          @_total_chunk, @_overall_chunk, @_unconcrete_affixes = nil
          @_usages, @_root_times, @_affixes_num = nil
          @_maximal_chunks, @_side_keys = nil
        end

        # The method for detection relations between
        # @return [Hash] the total links graph
        def links
          total_chunk.total_links
        end

        # @return [Hash]
        def overall_links
          overall_chunk.total_links
        end

        # Gets number of how many times the root chunks contains in total chunk
        # @return [Integer] the number of times
        def root_times
          @_root_times ||= usages.values.reduce(:+)
        end

        # Gets lateral reactoins grouped by number of internal chunks
        # @return [Hash] the grouping result
        def affixes_nums
          @_affixes_num ||= @affixes.group_by do |lateral_reaction|
            lateral_reaction.internal_chunks.size
          end
        end

        # Gets list of unique spec-atom pairs with sidepiece specs
        # @return [Array] the list of pairs
        def side_keys
          @_side_keys ||= clean_links.keys.select { |s, _| sidepiece_spec?(s) }
        end

        # Gets the lateral reaction which uses passed spec and atom
        # @param [Array] spec_atom by which the reaction will be found
        # @return [LateralReaction] the single lateral reaction
        def select_reaction(spec_atom)
          chunks_users = @root_chunks.select { |ch| ch.links[spec_atom] }
          if chunks_users.one?
            reaction_class(chunks_users.first.lateral_reaction)
          elsif chunks_users.empty?
            raise ArgumentError, 'No reactions for passed spec_atom'
          else
            raise ArgumentError, 'Too many reactions uses passed spec_atom'
          end
        end

        # Gets the ordered list of lateral reactions which are root lateral reactions
        # @param [Specie] specie which should be one of sidepiece species of reaction
        # @return [Array] the list of single lateral reactions
        # TODO: must be private (just for rspecs)
        def unconcrete_affixes
          @_unconcrete_affixes ||= @affixes.select(&:concretizable?)
        end

        # Gets the ordered list of lateral reactions which are root lateral reactions
        # and not uses maximal times passed specie
        #
        # @param [LateralReaction] creating_reaction which checks that it can be
        #   injecting to result unconcrete reaction or not
        # @param [Specie] specie which should be one of sidepiece species of reaction
        # @return [Array] the list of single lateral reactions
        def unconcrete_affixes_without(creating_reaction, specie)
          max_times = maximal_times_usage(specie)
          unconcrete_affixes.select do |lateral_reaction|
            mergeable?(lateral_reaction, creating_reaction) &&
              num_species_in(lateral_reaction, specie) < max_times
          end
        end

        # Checks that passed spec belongs to overall target specs set
        # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] spec
        #   which will be checked in the set of target specs
        # @return [Boolean] is target spec or not
        def target_spec?(spec)
          overall_chunk.target_specs.include?(spec)
        end

        # Checks that passed spec belongs to sidepiece specs set
        # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] spec
        #   which will be checked in the set of sidepiece specs
        # @return [Boolean] is sidepiece spec or not
        def sidepiece_spec?(spec)
          sidepiece_specs.include?(spec)
        end

      private

        attr_reader :generator

        # Gets total chunk which adsorbs root chunk in self
        # @return [Organizers::TotalChunk] the total chunk
        def total_chunk
          @_total_chunk ||= make_total_chunk(@root_chunks)
        end

        # Gets total chunk which adsorbs all chunk in self
        # @return [Organizers::TotalChunk] the overall chunk
        def overall_chunk
          @_overall_chunk ||= make_total_chunk(maximal_chunks)
        end

        # Makes total chunk instance
        # @param [Array] chunks from which the total chunk will be combined
        # @return [Organizers::TotalChunk] the total chunk
        def make_total_chunk(chunks)
          Organizers::TotalChunk.new(reaction.reaction, chunks)
        end

        # @return [Hash]
        def usages
          return @_usages if @_usages
          delta_chunk = overall_chunk
          sorted_chunks = @root_chunks.sort { |a, b| b <=> a }
          @_usages = sorted_chunks.each_with_object({}) do |root_chunk, acc|
            delta_chunk, num = next_delta_with_usage(delta_chunk, root_chunk)
            acc[root_chunk] = num
          end
        end

        # @param [TotalChunk | ChunkResidual] big_chunk
        # @param [BaseChunk] root_chunk
        # @return [ChunkResidual, Integer]
        def next_delta_with_usage(big_chunk, root_chunk)
          delta_chunk = big_chunk
          num = 0
          loop do
            next_delta = delta_chunk - root_chunk
            if next_delta
              delta_chunk = next_delta
              num += 1
            else
              return [delta_chunk, num]
            end
          end
        end

        # Selects chunks with maximal value of unique sidepiece species
        # @return [Array]
        def maximal_chunks
          return @_maximal_chunks if @_maximal_chunks

          sorted_chunks = @all_chunks.sort do |a, b|
            b.sidepiece_specs.size <=> a.sidepiece_specs.size
          end

          @_maximal_chunks =
            sorted_chunks.each_with_object([]) do |chunk, acc|
              acc << chunk if acc.all? do |ch|
                sss = [chunk, ch].map(&:sidepiece_specs)
                names = sss.map { |specs| specs.map(&:name) }
                names.reduce(:&).empty?
              end
            end
        end

        # Checks that passed reactions can be merged
        # @param [Array] reactions which provides merging internal chunks
        # @return [Boolean] is mergeable reactions or not
        def mergeable?(*reactions)
          typical_chunks = reactions.map(&:chunk)
          combined_chunks = typical_chunks.flat_map(&:internal_chunks)
          @affixes.any? do |lateral_reaction|
            inspecting_chunks = lateral_reaction.chunk.internal_chunks
            lists_are_identical?(inspecting_chunks, combined_chunks, &:same?)
          end
        end

        # Counts which times passed specie uses in sidepiece species of passed reaction
        # @param [LateralReaction] lateral_reaction for which the number of usages will
        #   be gotten
        # @param [Specie] specie which will be counted
        # @return [Integer] the number of specie usages in sidepiece species of lateral
        #   reaction
        def num_species_in(lateral_reaction, specie)
          lateral_reaction.sidepiece_species.count { |sp| sp == specie }
        end

        # Counts which times passed sidepiece specie uses in one lateral reaction
        # @param [Specie] specie for which the number will gotten
        # @return [Integer] the number of usage must be more than 1
        def maximal_times_usage(specie)
          @affixes.reduce(0) do |acc, lateral_reaction|
            [acc, num_species_in(lateral_reaction, specie)].max
          end
        end
      end
    end
  end
end
