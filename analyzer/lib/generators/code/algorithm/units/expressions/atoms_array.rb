module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Describes atoms array variable
        class AtomsArray < Core::Collection
          include LatticePositionReference

          # @param [Statement] body
          # @return [For]
          def each(body)
            iterate(:a, body)
          end

          # @param [Array] defined_vars
          # @param [AtomsArray] nbrs_arr
          # @param [Core::ObjectType] lattice
          # @param [Hash] rel_params
          # @return [Core::FunctionCall]
          def iterate_over_lattice(defined_vars, nbrs_arr, lattice, rel_params, body)
            ref = ref_rel(lattice, rel_params)
            iter_lambda = Core::Lambda[defined_vars, nbrs_arr, body]
            num = Core::Constant[items.size]
            mn = 'eachNeighbours'
            Core::FunctionCall[mn, self, ref, iter_lambda, template_args: [num]]
          end

          # @param [Array] defined_vars
          # @param [AtomVariable] nbr_var
          # @param [Core::ObjectType] lattice
          # @param [Hash] rel_params
          # @return [Core::FunctionCall]
          def nbr_from(defined_vars, nbr_var, lattice, rel_params, body)
            ref = ref_rel_at(lattice, rel_params)
            iter_lambda = Core::Lambda[defined_vars, nbr_var, body]
            Core::FunctionCall['neighbourFrom', self, ref, iter_lambda]
          end

        private

          # @param [Core::ObjectType] lattice
          # @param [Hash] rel_params
          # @return [Core::OpRef]
          def ref_rel_at(lattice, rel_params)
            ref_to(lattice, rel_name_at(rel_params))
          end

          # @param [Hash] rel_params
          # @return [String]
          def rel_name_at(rel_params)
            "#{rel_name(rel_params)}_at"
          end
        end

      end
    end
  end
end
