module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm::Units

        # Builds the coupled conditions tree
        class LateralSelectorCoupledUnit < LateralSelectorLimitedUnit
          include ReactionsUser

          # @param [EngineCode] generator of engine code
          # @param [Expressions::VarsDictionary] dict
          # @param [Array] group
          def initialize(generator, dict, group)
            super(dict, group)
            @generator = generator
          end

        private

          attr_reader :generator

          # @return [Boolean]
          def with_singular?
            group.first.first == 1
          end

          # @yield statement incorporating to else branch
          # @return [Expressions::Core::Condition]
          # @override
          def conditions_tree(&block)
            dict.make_chunks_counter.define_var + super
          end

          # @param [Integer] quant the number of similar reactions
          # @return [Expressions::Core::Statement]
          # @override
          def check_total_num(quant)
            if quant == 1 && with_singular?
              checking_exprs = check_root_chunks_exprs.sort_by(&:code)
              additional_check = Expressions::Core::OpOr[*checking_exprs]
              tail = Expressions::Core::OpRoundBks[additional_check]
              Expressions::Core::OpAnd[super, tail]
            else
              super
            end
          end

          # @return [Array]
          def check_root_chunks_exprs
            min_chunks = group.first.last
            min_chunks.map { |reaction| check_chunks_num(1, reaction) }
          end

          # @param [Integer] quant
          # @param [LateralReaction] reaction
          # @return [Expressions::Core::OpEq]
          def check_chunks_num(quant, reaction)
            compare_nums(quant, dict.counter_item(reaction.enum_name))
          end

          # @param [LateralReaction] reaction
          # @return [Expressions::Core::OpAnd]
          def check_chunks_of(reaction)
            gs = reaction.internal_chunks.groups
            sub_group =
              gs.map { |g| [g.size, reaction_class(g.first.lateral_reaction)] }
            checks = sub_group.map { |q, r| check_chunks_num(q, r) }
            Expressions::Core::OpAnd[*checks.sort_by(&:code)]
          end

          # @param [Integer] quant the number of similar reactions
          # @param [Array] reactions which instances will creating in branch
          # @return [Expressions::Core::Condition]
          # @override
          def branch_body(quant, reactions)
            quant == 1 ? super : sub_tree(reactions)
          end

          # @param [Array] reactions which instances will be checked
          # @return [Expressions::Core::Condition]
          def sub_tree(reactions)
            call_procs(sub_procs(reactions))
          end

          # @param [Array] reactions
          # @return [Array]
          def sub_procs(reactions)
            reactions.map do |reaction|
              -> &block { sub_branch(reaction, &block) }
            end
          end

          # @param [LateralReaction] reaction
          # @yield statement incorporating to else branch
          # @return [Expressions::Core::Condition]
          def sub_branch(reaction, &block)
            make_branch(check_chunks_of(reaction), sub_body(reaction), &block)
          end

          # @param [LateralReaction] reaction
          # @return [Expressions::Core::Return]
          def sub_body(reaction)
            Expressions::Core::Return[allocate_chunk(reaction)].freeze
          end
        end

      end
    end
  end
end
