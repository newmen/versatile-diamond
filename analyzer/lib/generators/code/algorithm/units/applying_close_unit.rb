module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Providers methods to terminate reaction applying algorithm
        class ApplyingCloseUnit

          # @param [Expressions::TargetsDictionary] dict
          # @param [Array] sources
          def initialize(dict, sources)
            @dict = dict
            @sources = sources
            @removing = @sources.select { |node| node.product.gas? }
          end

          # @return [Expressions::Core::Statement]
          def finish
            ((@removing.empty? ? [] : [remove_atoms]) + [finder_call]).reduce(:+)
          end

        private

          # @return [Expressions::Core::Statement]
          def remove_atoms
            vars = @removing.map { |node| @dict.var_of(node.atom) }
            vars.map(&:mark_to_remove).reduce(:+)
          end

          # @return [Expressions::Core::FunctionCall]
          def finder_call
            var = @dict.var_of(@sources.map(&:atom))
            Expressions::FinderClass[].find_all(var)
          end
        end

      end
    end
  end
end
