module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Iterates symmetric atoms which does not belong to one specie
        class SymmetricAtomsForLoop < Core::For
        private

          ITERATOR_TYPE = Core::ScalarType['uint'].freeze
          ITERATOR_INIT_VALUE = Core::Constant[0].freeze
          ITERABLE_VAR =
            Core::Variable[:a, ITERATOR_TYPE, 'a', ITERATOR_INIT_VALUE].freeze

          INDEXES = [
            ITERABLE_VAR,
            Core::OpMinus[Core::Constant[1], ITERABLE_VAR]
          ].freeze

        public

          class << self
            # @param [Array] atoms_vars
            # @param [Core::Expression] body
            # @return [SymmetricAtomsForLoop]
            def [](atoms_vars, body)
              if atoms_vars.all?(&:var?)
                update_atoms_indexes!(atoms_vars)

                assign = ITERABLE_VAR.define_var
                cond = Core::OpLess[ITERABLE_VAR, Core::Constant[atoms_vars.size]]
                op = Core::OpRInc[ITERABLE_VAR]
                super(assign, cond, op, body)
              else
                arg_err!("Incorrect iterable variables #{atoms_vars}")
              end
            end

          private

            # @param [Array]
            def update_atoms_indexes!(atoms_vars)
              atoms_vars.zip(INDEXES).each { |v, i| v.update_index!(i) }
            end
          end
        end

      end
    end
  end
end
