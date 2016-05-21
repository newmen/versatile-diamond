module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The unit for combines statements of lateral reaction creation
        class CheckLateralsCreationUnit < LateralChunksCreationUnit
          include ReactantAbstractType

          # @param [Expressions::VarsDictionary] dict
          # @param [ReactionContextProvider] context
          # @param [LateralChunks] lateral_chunks
          def initialize(dict, context, lateral_chunks)
            super(dict, context)
            @lateral_chunks = lateral_chunks

            @_key_nodes = nil
          end

        private

          CHAIN_FACTORY_VAR_NAME = 'factory'.freeze

          # @return [Array]
          def sidepiece_nodes
            @_key_nodes ||= context.key_nodes
          end

          # @return [Instances::UniqueReactant]
          def target_sidepiece
            species = sidepiece_nodes.map(&:uniq_specie).uniq
            if species.one?
              species.first
            else
              raise 'Too many sidepiece species for check lateral reactions'
            end
          end

          # @return [Array]
          def checking_reactions
            specie = target_sidepiece.original
            @lateral_chunks.unconcrete_affixes_without(lateral_reaction, specie)
          end

          # @return [String]
          def source_specie_name
            Specie::TARGET_SPECIE_NAME
          end

          # @param [Array] exprs
          # @return [Expressions::Core::OpCombine]
          def call_create(*exprs)
            var = factory_var
            var.define_var(dict.var_of(target_sidepiece), *exprs) +
              var.member('checkoutReactions', template_args: checking_reaction_types)
          end

          # @return [Expressions::Core::Variable]
          def factory_var
            args = [lateral_factory_type, lateral_reaction_type, typical_reaction_type]
            type = Expressions::Core::ObjectType['ChainFactory', template_args: args]
            Expressions::Core::Variable[:chain_factory, type, CHAIN_FACTORY_VAR_NAME]
          end

          # @return [Expressions::Core::ObjectType]
          def lateral_factory_type
            prefix = uniq_side_nodes.one? ? 'Uno' : 'Duo'
            Expressions::Core::ObjectType["#{prefix}LateralFactory"]
          end

          # @return [Expressions::Core::ObjectType]
          def typical_reaction_type
            Expressions::Core::ObjectType[@lateral_chunks.reaction.class_name]
          end

          # @return [Array]
          def checking_reaction_types
            checking_reactions.map do |reaction|
              Expressions::Core::ObjectType[reaction.class_name]
            end
          end
        end

      end
    end
  end
end
