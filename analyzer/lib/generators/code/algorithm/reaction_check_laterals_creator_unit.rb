module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # The instance of class could defines all neccessary variables and calls
        # engine framework method for concretize side reaction which was found
        class ReactionCheckLateralsCreatorUnit
          include CommonCppExpressions
          include AtomCppExpressions

          FACTORY_VAR_NAME = 'factory'

          # Initializes the creator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [LateralChunk] lateral_chunks which provides common links graph
          # @param [LateralReaction] lateral_reaction which will created by current
          #   block
          # @param [UniqSpecie] target specie from which the find algorithm doing
          # @param [Array] sidepieces the list of sidepiece species from which lateral
          #   reactions will be checked
          def initialize(namer, lateral_chunks, lateral_reaction, target, sidepieces)
            @namer = namer
            @lateral_chunks = lateral_chunks
            @lateral_reaction = lateral_reaction
            @target_specie = target
            @sidepiece_species = sidepieces
          end

          # Gets the cpp code lines with concretization of lateral reactions
          # @return [String] the cpp code lines with concretization reaction call
          def lines
            define_checking_factory + checkout_reactions_call
          end

        private

          attr_reader :namer, :lateral_chunks, :lateral_reaction
          attr_reader :target_specie, :sidepiece_species

          # Gets typical reaction of current algorithm
          # @return [TypicalReaction] the main reaction
          def typical_reaction
            lateral_chunks.reaction
          end

          # Gets the list of checking factory template arguments
          # @return [Array] the list of types which will used as template arguments of
          #   checking factory
          def factory_template_args
            [
              factory_class_name,
              lateral_reaction.class_name,
              typical_reaction.class_name
            ]
          end

          # Gets cpp code with type of checking lateral reactions factory
          # @return [String] the type of checking factory
          def factory_comp_type
            template_call('ChainFactory', factory_template_args)
          end

          # Gets the list of factory constructor arguments
          # @return [Array] the list of species variables names
          def names_arr
            [target_specie, sidepiece_species].map { |s| namer.name_of(s) }
          end

          # Gets cpp code with definition of checking lateral reactions factory
          # @return [String] the cpp lines with factory definition
          def define_checking_factory
            args_str = names_arr.join(', ')
            code_line("#{factory_comp_type} #{FACTORY_VAR_NAME}(#{args_str});")
          end

          # Gets cpp code with call checkoutReactions template method of factory
          # @return [String] the cpp lines with checkoutReactions method call
          def checkout_reactions_call
            types = checking_reactions.map(&:class_name)
            prefix = template_call("#{FACTORY_VAR_NAME}.checkoutReactions", types)
            code_line("#{prefix}();")
          end

          # Gets template call
          # @param [String] aim of template call
          # @param [Array] template_args the list of template arguments
          # @return [String] cpp code with template call
          def template_call(aim, template_args)
            if template_args.size == 1
              "#{aim}<#{template_args.first}>"
            else
              args_str = template_args.join(",\n")
              "#{aim}<\n#{shift_code(args_str)}\n>"
            end
          end

          # Gets ordered list of checking lateral reactions
          # @return [Array] the list of reactions which will checked
          def checking_reactions
            args = [lateral_reaction, target_specie.original]
            lateral_chunks.unconcrete_affixes_without(*args)
          end

          # Gets name of checking factory class
          # @return [String] the cpp code string with call
          def factory_class_name
            prefix = sidepiece_species.all_equal?(&:original) ? 'Uno' : 'Duo'
            "#{prefix}LateralFactory"
          end
        end

      end
    end
  end
end
