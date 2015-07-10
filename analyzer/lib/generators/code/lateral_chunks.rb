module VersatileDiamond
  module Generators
    module Code

      # Contains logic for description of common graph of all possible chunks of some
      # typical reaction
      class LateralChunks
        include Modules::RelationBetweenChecker
        extend Forwardable

        def_delegators :total_chunk, :total_links, :clean_links, :sidepiece_specs

        # Initializes meta object which provides useful methods for code generators
        # @param [TypicalReaction] reaction from which the chunks of children lateral
        #   reactions will be wrapped
        # @param [Array] all_chunks of children lateral reactions of passed reaction
        # @param [Array] root_chunks of children lateral reactions of passed reaction
        def initialize(reaction, all_chunks, root_chunks)
          @reaction = reaction
          @all_chunks = all_chunks
          @root_chunks = root_chunks

          @_total_chunk = nil
        end

        # Gets number of how many times the root chunks contains in total chunk
        # @return [Integer] the number of times
        def root_times
          result = total_chunk
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

        # Counts chunks which uses at least one spec from passed list
        # @param [Array] specs each of which will checked in each internal unit chunks
        # @return [Integer] the number of chunks which uses passed specs
        def count_chunks(specs)
          chunks_users(specs).size
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
          @_total_chunk ||= Organizers::TotalChunk.new(@reaction, @all_chunks)
        end

        # The method for detection relations between
        # @return [Hash] the total links graph
        def links
          total_links
        end

        # Selects chunks which uses at least one spec from passed list
        # @param [Array] specs each of which will checked in each internal unit chunks
        # @return [Array] the list of chunks which uses passed specs
        def chunks_users(specs)
          @all_chunks.select do |ch|
            specs.any? { |spec| ch.sidepiece_specs.include?(spec) }
          end
        end
      end
    end
  end
end
