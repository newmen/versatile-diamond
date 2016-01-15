module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Contain logic for building algorithm of selection (and creation) correct
        # lateral reaction from passed set of available chunks
        class LateralReactionSelectBuilder
          include ReactionsUser
          include CommonCppExpressions
          extend Forwardable

          CHUNKS_VAR_NAME = 'chunks'.freeze
          NUM_VAR_NAME = 'num'.freeze
          COUNTER_VAR_NAME = 'counter'.freeze

          # @param [EngineCode] generator the major engine code generator
          # @param [LateralChunks] lateral_chunks the target object by which the
          #   algorithm will be generated
          def initialize(generator, lateral_chunks)
            @generator = generator
            @namer = NameRemember.new

            affixes_groups = sort_groups(lateral_chunks.affixes_nums.to_a)
            @limited = apply_splitter_to(affixes_groups, :select)
            @coupled = apply_splitter_to(affixes_groups, :reject)
          end

          # Builds algorithm
          # @return [String] the cpp code with algorithm of selectFrom method body
          def build
            if has_limited?
              combine_code(main_sequence) + safe_assert
            else
              coupling_creations
            end
          end

        private

          attr_reader :generator, :namer, :limited, :coupled
          def_delegator :namer, :name_of

          # Checks that limited reactions are presented
          # @return [Boolean] are exist limited reactions or not
          def has_limited?
            !limited.empty?
          end

          # Checks that coupled reactions are presented
          # @return [Boolean] are exist coupled reactions or not
          def has_coupled?
            !coupled.empty?
          end

          # Makes the conditions code by passed sequence
          # @param [Array] sequence of triples where each triple is: flag of using else
          #   prefix, conditions expression string and condition body string
          # @return [String] the cpp code with checking conditions
          def combine_code(sequence)
            code_blocks(sequence).join
          end

          # Makes blocks of conditions by passed sequence
          # @param [Array] sequence of triples where each triple is: flag of using else
          #   prefix, conditions expression string and condition body string
          # @return [Array] the list of condition parts
          def code_blocks(sequence)
            sequence.map do |use_else_prefix, condition_str, body_str|
              code_condition(condition_str, use_else_prefix: use_else_prefix) do
                body_str
              end
            end
          end

          ### --------------------------------------------------------------------- ###

          # Gets the main sequence of selecting lateral reaction
          # @return [Array] the list of triples
          def main_sequence
            main_else_prefixes.zip(main_conditions, main_bodies)
          end

          # Gets the list of main condition expressions
          # @return [Array] the list of condition strings for each condition statement
          def main_conditions
            if has_coupled?
              limited_conditions + [nil]
            else
              limited_conditions
            end
          end

          # Gets the list of bodies for generating conditions
          # @return [Array] the main condition bodies of selecting algorithm
          def main_bodies
            if has_coupled?
              limited_bodies + [coupling_creations]
            else
              limited_bodies
            end
          end

          # Gets list of flags where each flag is identifier that the else prefix
          # should be used
          #
          # @return [Array] the list of using else prefix flags
          def main_else_prefixes
            if has_coupled?
              make_else_prefixes(limited.size)
            else
              make_else_prefixes(limited.size - 1)
            end
          end

          ### --------------------------------------------------------------------- ###

          # Gets the list of condition strings for limited reactions
          # @return [Array] the list of conditions which guards selection of limited
          #   reaction
          def limited_conditions
            limited.map(&:first).map(&method(:check_num_condition))
          end

          # Gets the list of condition bodies for limited reactions
          # @return [Array] the list of condition bodies where limited reactions
          #   creates
          def limited_bodies
            simple_creations(limited.map { |num, reactions| [num, reactions.first] })
          end

          ### --------------------------------------------------------------------- ###

          # Gets the code line with defined counter container variable
          # @return [String] the cpp code with variable definition
          def define_counter
            type = 'std::unordered_map<ushort, ushort>'
            counter_func_call = "countReactions(#{CHUNKS_VAR_NAME}, #{NUM_VAR_NAME})"
            code_line("#{type} #{COUNTER_VAR_NAME} = #{counter_func_call};")
          end

          # Gets the body for checking the coupled reactions
          # @return [String] the cpp string where coupled reactions checks
          def coupling_creations
            define_counter + combine_code(coupling_sequence) + strong_assert
          end

          # Gets the sequence of selecting coupled lateral reaction
          # @return [Array] the list of triples
          def coupling_sequence
            coupling_else_prefixes.zip(coupling_conditions, coupling_bodies)
          end

          # Gets the list of condition strings for coupled reactions
          # @return [Array] the list of conditions which guards selection of coupled
          #   reaction
          def coupling_conditions
            coupled.flat_map do |num, reactions|
              num_condition = [check_num_condition(num)]
              if num == 1
                conds = reactions.flat_map(&method(:reactions_conditions))
                conds_str = ["(#{conds.join(' || ')})"]
                [(num_condition + conds_str).join(' && ')]
              else
                reactions.map do |reaction|
                  (num_condition + reactions_conditions(reaction)).join(' && ')
                end
              end
            end
          end

          # Gets the list of condition bodies for coupled reactions
          # @return [Array] the list of condition bodies where coupled reactions
          #   creates
          def coupling_bodies
            reactions_with_nums = coupled.flat_map do |num, reactions|
              if num == 1
                [[num, reactions.first]]
              else
                reactions.map { |reaction| [num, reaction] }
              end
            end
            simple_creations(reactions_with_nums)
          end

          # Gets list of flags for coupled reactions where each flag is identifier that
          # the else prefix should be used
          #
          # @return [Array] the list of using else prefix flags
          def coupling_else_prefixes
            observing_nums = coupled.reduce(0) do |acc, (num, reactions)|
              acc + (num == 1 ? 1 : reactions.size)
            end
            make_else_prefixes(observing_nums - 1)
          end

          ### --------------------------------------------------------------------- ###

          # Gets the array of condition strings for passed reaction
          # @param [LateralReaction] reaction for which the conditions will be combined
          # @return [Array] the list of condition strings
          def reactions_conditions(reaction)
            groups = reactions_nums(reaction)
            groups.map do |num, reaction|
              counter_item = counter(reaction.enum_name)
              "#{counter_item} == #{num}"
            end
          end

          # Counts internal smallest reactions in passed reaction
          # @param [LateralReaction] reaction for which the smallest internal reactions
          #   will be counted
          # @return [Array] the sorted list of counted smallest internal reactions
          def reactions_nums(reaction)
            chunks_groups = reaction.internal_chunks.groups
            reactions_groups = chunks_groups.map do |group|
              [group.size, reaction_class(group.first.lateral_reaction)]
            end
            sort_groups(reactions_groups)
          end

          ### --------------------------------------------------------------------- ###

          # Makes the sequence of else prefix flags
          # @param [Integer] else_nums the number of generating else prefixes
          # @return [Array] the list of else prefix flags
          def make_else_prefixes(else_nums)
            [false] + [true] * else_nums
          end

          # Gets the list of creation lines for passed reactions
          # @param [Array] reactions_with_nums the list of pairs where the first item
          #   of pair is the number of reactions which contained in the second item
          # @return [Array] the list of creating lines
          def simple_creations(reactions_with_nums)
            reactions_with_nums.map { |args| creation_line(*args) }
          end

          # Makes creation line for passed reaction corresponding to the number of
          # similar reactions
          #
          # @param [Integer] num the number of similar reactions
          # @param [LateralReaction] reaction which instance will creating in result
          #   line
          # @return [String] the code line with reaction selection
          def creation_line(num, reaction)
            result =
              if num == 1
                "#{CHUNKS_VAR_NAME}[0]"
              else
                "new #{reaction.class_name}(#{CHUNKS_VAR_NAME})"
              end
            code_line("return #{result};")
          end

          # Gets condition expression where checks the value of incoming number of
          # available chunks
          #
          # @param [Integer] num the number which will compares with incoming number of
          #   available chunks
          # @return [String] the coparison condition expression
          def check_num_condition(num)
            "#{NUM_VAR_NAME} == #{num}"
          end

          # Gets access to counter container item by passed index
          # @param [String] index of counter item
          # @return [String] the call of counter item
          def counter(index)
            "#{COUNTER_VAR_NAME}[#{index}]"
          end

          # Gets lines with strong assertion if it need
          # @return [String] the lines with assertion or empty string when assertion
          #   is excess
          def safe_assert
            has_coupled? ? '' : strong_assert
          end

          # Gets lines with strong assertion
          # @return [String] the lines with assertion
          def strong_assert
            code_lines('assert(false);', 'return nullptr;')
          end

          # Sorts passed list of pairs by first item of each pair
          # @param [Array] groups the list which will be sorted
          # @return [Array] the sorted pairs list
          def sort_groups(groups)
            groups.sort_by(&:first)
          end

          # Selects reactions from affixes groups by passed method
          # @param [Array] affixes_groups from which the target reactions will be
          #   selected
          # @param [Symbol] filter_name the name of method by which the selection will
          #   be done
          # @return [Array] the list of selected groups
          def apply_splitter_to(affixes_groups, filter_name)
            affixes_groups.public_send(filter_name) { |_, rs| rs.one? }
          end
        end

      end
    end
  end
end
