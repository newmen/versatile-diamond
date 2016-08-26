module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Provides methods for reference to lattice positions
        module LatticePositionReference
        private

          # @param [Core::ObjectType] lattice
          # @param [String] rel_method_name
          # @return [Core::OpRef]
          def ref_to(lattice, rel_method_name)
            lattice.member_ref(Core::Constant[rel_method_name])
          end

          # @param [Core::ObjectType] lattice
          # @param [Hash] rel_params
          # @return [Core::OpRef]
          def ref_rel(lattice, rel_params)
            ref_to(lattice, rel_name(rel_params))
          end

          # @param [Core::ObjectType] lattice
          # @param [Hash] rel_params
          # @return [Core::OpRef]
          def ref_rel_at(lattice, rel_params)
            ref_to(lattice, rel_name_at(rel_params))
          end

          # @param [Core::ObjectType] lattice
          # @param [Hash] rel_params
          # @param [Array] args
          # @return [Core::OpNs]
          def lattice_call_at(lattice, rel_params, *args)
            nbrs_seq = Core::OpBraces[Core::OpSequence[*args], multilines: false]
            Core::OpNs[lattice, Core::FunctionCall[rel_name_at(rel_params), nbrs_seq]]
          end

          # @param [Hash] rel_params
          # @return [String]
          def rel_name(rel_params)
            "#{rel_params[:dir]}_#{rel_params[:face]}"
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
