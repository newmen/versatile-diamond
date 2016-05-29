module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Builds the conditions tree for lateral reaction selecting
        class LateralSelectorLimitedUnit
          include Modules::ProcsReducer

          TIN_CAP = Expressions::Core::Constant[''].freeze

          # @param [Expressions::VarsDictionary] dict
          # @param [Array] group
          def initialize(dict, group)
            @dict = dict
            @group = group.sort_by(&:first)
          end

          # @yield statement incorporating to else branch
          # @return [Expressions::Core::Condition]
          def chose_chunk(&block)
            if group.empty?
              block_given? ? block.call : TIN_CAP
            else
              conditions_tree(&block)
            end
          end

        private

          attr_reader :dict, :group

          # @yield statement incorporating to else branch
          # @return [Expressions::Core::Condition]
          def conditions_tree(&block)
            call_procs(slice_procs, &block)
          end

          # @return [Array]
          def slice_procs
            group.map do |quant, reactions|
              -> &block { case_branch(quant, reactions, &block) }
            end
          end

          # @param [Integer] quant the number of similar reactions
          # @param [Array] reactions which instances will creating in branch
          # @yield statement incorporating to else branch
          # @return [Expressions::Core::Condition]
          def case_branch(quant, reactions, &block)
            make_branch(check_total_num(quant), branch_body(quant, reactions), &block)
          end

          # @param [Array] check_and_body
          # @yield statement incorporating to else branch
          # @return [Expressions::Core::Condition]
          def make_branch(*check_and_body, &block)
            args = check_and_body.dup
            if block_given?
              block_result = block.call
              args << block_result unless block_result == TIN_CAP
            end
            Expressions::Core::Condition[*args].freeze
          end

          # @param [Integer] quant the number of similar reactions
          # @return [Expressions::Core::OpEq]
          def check_total_num(quant)
            compare_nums(quant, dict.var_of(:num))
          end

          # @param [Integer] quant the number of similar reactions
          # @return [Expressions::Core::Variable] var
          # @return [Expressions::Core::OpEq]
          def compare_nums(quant, var)
            Expressions::Core::OpEq[var, Expressions::Core::Constant[quant]].freeze
          end

          # @param [Integer] quant the number of similar reactions
          # @param [Array] reactions which instances will creating in branch
          # @return [Expressions::Core::Return]
          def branch_body(quant, reactions)
            Expressions::Core::Return[result_value(quant, reactions.first)].freeze
          end

          # @param [Integer] quant the number of similar reactions
          # @param [LateralReaction] reaction which instance will creating in branch
          # @return [Expressions::Core::Expression]
          def result_value(quant, reaction)
            quant == 1 ? dict.var_of(:first_chunk) : allocate_chunk(reaction)
          end

          # @param [LateralReaction] reaction which instance will creating in branch
          # @return [Expressions::Core::Allocate]
          def allocate_chunk(reaction)
            type = Expressions::Core::ObjectType[reaction.class_name]
            Expressions::Core::Allocate[type, dict.var_of(:chunks_list)].freeze
          end
        end

      end
    end
  end
end
