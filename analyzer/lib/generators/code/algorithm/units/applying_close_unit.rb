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
            @removing = sources.select { |src| src.product.gas? }
            @atoms = sources.map(&:atom)
          end

          # @return [Expressions::Core::Statement]
          def finish
            exprs = []
            exprs << remove_atoms unless @removing.empty?
            exprs << redefine_atoms unless @dict.var_of(@atoms)
            exprs << finder_call
            exprs.reduce(:+)
          end

        private

          # @return [Expressions::Core::Statement]
          def remove_atoms
            vars = @removing.map { |node| @dict.var_of(node.atom) }
            vars.map(&:mark_to_remove).reduce(:+)
          end

          # @return [Expressions::Core::Variable]
          def redefine_atoms
            @dict.make_atom_s(@atoms).define_var
          end

          # @return [Expressions::Core::FunctionCall]
          def finder_call
            Expressions::FinderClass[].find_all(@dict.var_of(@atoms))
          end
        end

      end
    end
  end
end
