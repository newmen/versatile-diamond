module VersatileDiamond
  module Generators
    module Code

      # Contains logic for description of common graph of all possible chunks of some
      # typical reaction
      class LateralChunks
        include Modules::RelationBetweenChecker
        extend Forwardable

        attr_reader :reaction
        def_delegators :total_chunk, :clean_links,
          :sidepiece_specs # just for tests

        # Initializes meta object which provides useful methods for code generators
        # @param [EngineCode] generator of engine code
        # @param [TypicalReaction] reaction from which the chunks of children lateral
        #   reactions will be wrapped
        # @param [Array] all_chunks of children lateral reactions of passed reaction
        # @param [Array] root_chunks of children lateral reactions of passed reaction
        def initialize(generator, reaction, all_chunks, root_chunks)
          @generator = generator
          @reaction = reaction
          @all_chunks = all_chunks
          @root_chunks = root_chunks

          @_total_chunk = nil
        end

        # The method for detection relations between
        # @return [Hash] the total links graph
        def links
          total_chunk.total_links
        end

        # Gets number of how many times the root chunks contains in total chunk
        # @return [Integer] the number of times
        def root_times
          result = make_total_chunk(@all_chunks)
          @root_chunks.reduce(0) do |acc, chunk|
            num = 0
            loop do
              next_result = result - chunk
              break unless next_result

              num += 1
              result = next_result
            end

            acc + num
          end
        end

        # Gets the lateral reaction which uses passed spec and atom
        # @param [Array] spec_atom by which the reaction will be found
        # @return [LateralReaction] the single lateral reaction
        def select_reaction(spec_atom)
          chunks_users = @root_chunks.select { |ch| ch.links[spec_atom] }
          raise 'Too many reactions uses passed spec_atom' if chunks_users.size > 1

          chunk = chunks_users.first
          @generator.reaction_class(chunk.lateral_reaction.name)
        end

        # Checks that passed spec belongs to target specs set
        # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] spec
        #   which will be checked in the set of target specs
        # @return [Boolean] is target spec or not
        def target_spec?(spec)
          total_chunk.target_specs.include?(spec)
        end

      private

        # Gets total chunk which adsorbs all chunk in self
        # @return [Organizers::TotalChunk] the total chunk
        def total_chunk
          @_total_chunk ||= make_total_chunk(@root_chunks)
        end

        # Makes total chunk instance
        # @param [Array] chunks from which the total chunk will be combined
        # @return [Organizers::TotalChunk] the total chunk
        def make_total_chunk(chunks)
          Organizers::TotalChunk.new(reaction, chunks)
        end
      end
    end
  end
end
