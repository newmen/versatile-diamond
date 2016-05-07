module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides methods for specie pure units
        module SpeciePureMethods
          include Algorithm::Units::SpecieAbstractType

          def define_atom_anchor!
            kwargs = { name: Code::Specie::ANCHOR_ATOM_NAME, next_name: false }
            dict.make_atom_s(atoms.first, **kwargs)
          end

          def define_specie_anchor!
            kwargs = { name: Code::Specie::ANCHOR_SPECIE_NAME, next_name: false }
            dict.make_specie_s(species.first, **kwargs)
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_different_atoms_roles(&block)
            checking_nodes = incoming_nodes.dup
            if checking_nodes.empty?
              block.call
            else
              check_atoms_roles(checking_nodes.map(&:atom), &block)
            end
          end

        private

          # @return [Array]
          def incoming_nodes
            nodes.reject(&:coincide?).select do |n|
              dict.var_of(n.uniq_specie) &&
                (dict.var_of(n.atom) || !n.properties.include?(n.sub_properties))
            end
          end
        end

      end
    end
  end
end
