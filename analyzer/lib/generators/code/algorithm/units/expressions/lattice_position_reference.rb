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
            rel_call = Core::FunctionCall[rel_method_name]
            Core::OpRef[Core::OpNs[lattice, rel_call]]
          end

          # @param [Core::ObjectType] lattice
          # @param [Hash] rel_params
          # @return [Core::OpRef]
          def ref_rel(lattice, rel_params)
            ref_to(lattice, rel_name(rel_params))
          end

          # @param [Hash] rel_params
          # @return [String]
          def rel_name(rel_params)
            "#{rel_params[:dir]}_#{rel_params[:face]}"
          end
        end

      end
    end
  end
end
