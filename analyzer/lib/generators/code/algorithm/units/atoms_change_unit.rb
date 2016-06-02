module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Providers methods to apply changes in reaction applying algorithm
        class AtomsChangeUnit
          include Modules::ProcsReducer

          # @param [Expressions::TargetsDictionary] dict
          # @param [ChangesContextProvider] context
          # @param [Array] sources
          def initialize(dict, context, sources)
            @dict = dict
            @context = context
            @sources = sources

            @phase_changes = @context.phase_changes

            @_recharges, @_neighbours_difference = nil
            @_create_bond_calls, @_drop_bond_calls = nil
          end

          # @return [Expressions::Core::Statement]
          def apply
            exprs = []
            exprs << change_phases unless @phase_changes.empty?
            exprs << recharge unless recharges.empty?
            exprs << create_bond_calls.reduce(:+) unless create_bond_calls.empty?
            exprs << drop_bond_calls.reduce(:+) unless drop_bond_calls.empty?
            exprs << change_roles
            exprs.reduce(:+)
          end

        private

          # @return [Expressions::Core::Statement]
          def change_phases
            @phase_changes.map(&method(:change_phase_for)).reduce(:+)
          end

          # @param [Nodes::SourceNode] src
          # @return [Expressions::Core::Statement]
          def change_phase_for(src)
            prd = src.product
            var = @dict.var_of(src.atom)
            if src.gas?
              if prd.lattice
                var.insert_to_crystal(*insertion_args_of(src))
              else
                var.insert_to_amorph
              end
            elsif prd.gas?
              src.lattice ? var.erase_from_crystal : var.erase_from_amorph
            elsif src.lattice && !prd.lattice
              var.erase_from_crystal + var.insert_to_amorph
            elsif !src.lattice && prd.lattice
              var.erase_from_amorph + var.insert_to_crystal(*insertion_args_of(src))
            end
          end

          # @param [Nodes::SourceNode] node
          # @return [Array]
          def insertion_args_of(node)
            nbrs, rel_params = @context.latticed_neighbours_of(node)
            [@dict.var_of(nbrs.first.atom).crystal, coords_call(nbrs, rel_params)]
          end

          # @param [Array] nodes
          # @param [Hash] rel_params
          # @return [Expressions::Core::FunctionCall]
          def coords_call(nodes, rel_params)
            a1, a2 = nodes.map { |node| @dict.var_of(node.atom) }
            lattice =
              Expressions::Core::ObjectType[nodes.first.lattice_class.class_name]
            a1.coords_with(a2, lattice, rel_params)
          end

          ### --------------------------------------------------------------------- ###

          # @return [Expressions::Core::Statement]
          def recharge
            exprs = recharges.map { |n, delta| @dict.var_of(n.atom).recharge(delta) }
            exprs.reduce(:+)
          end

          # @return [Array]
          def recharges
            @_recharges ||= sources_with_deltas.reject { |_, delta| delta == 0 }
          end

          # @return [Array]
          def sources_with_deltas
            @sources.map do |src|
              a, b = [src, src.product].map(&:properties).map(&:unbonded_actives_num)
              [src, b - a]
            end
          end

          ### --------------------------------------------------------------------- ###

          # @return [Array]
          def neighbours_difference
            @_neighbours_difference ||= @sources.map do |node|
              [node, both_differences(node).map { |prds| prds.map(&:source) }]
            end
          end

          # @param [Nodes::SourceNode] node
          # @return [Array]
          def both_differences(node)
            reflected, related = two_way_products(node).map(&:to_set)
            [reflected - related, related - reflected].map(&:to_a)
          end

          # @param [Nodes::SourceNode] node
          # @return [Array]
          def two_way_products(node)
            [
              @context.direct_neighbours_of(node).map(&:product),
              @context.direct_neighbours_of(node.product)
            ]
          end

          # @return [Array]
          def create_bond_calls
            @_create_bond_calls ||=
              neighbours_difference.flat_map do |node, (diff, _)|
                var = @dict.var_of(node.atom)
                nbrs = node.gas? && !node.product.gas? ? diff + [node] : diff
                nbrs.map { |n| var.bond_with(@dict.var_of(n.atom)) }
              end
          end

          # @return [Array]
          def drop_bond_calls
            @_drop_bond_calls ||=
              neighbours_difference.flat_map do |node, (_, nbrs)|
                var = @dict.var_of(node.atom)
                nbrs.map { |n| var.unbond_from(@dict.var_of(n.atom)) }
              end
          end

          ### --------------------------------------------------------------------- ###

          # @return [Expressions::Core::Statement]
          def change_roles
            @sources.reject(&:gas?).map(&method(:change_role_of)).reduce(:+)
          end

          # @param [Nodes::SourceNode] node
          # @return [Expressions::Core::Statement]
          def change_role_of(node)
            exprs = node.wrong_roles.empty? ? [] : [assert_wrong_roles(node)]
            exprs << change_role_tree(node) unless node.transitions.empty?
            exprs.reduce(:+)
          end

          # @param [Nodes::SourceNode] node
          # @return [Expressions::Core::Assert]
          def assert_wrong_roles(node)
            var = @dict.var_of(node.atom)
            calls = node.wrong_roles.map(&var.public_method(:role_as))
            checks_not = calls.map(&Expressions::Core::OpNot.public_method(:[]))
            Expressions::Core::Assert[Expressions::Core::OpAnd[*checks_not]]
          end

          # @param [Nodes::SourceNode] node
          # @return [Expressions::Core::Statement]
          def change_role_tree(node)
            call_procs(change_role_procs(node))
          end

          # @param [Nodes::SourceNode] node
          # @return [Array]
          def change_role_procs(node)
            var = @dict.var_of(node.atom)
            node.transitions.map do |transition|
              -> &block { change_role_branch(var, *transition, &block) }
            end
          end

          # @param [Expressions::AtomVariable] var
          # @param [Integer] from role index
          # @param [Integer] to role index
          # @yield statement incorporating to else branch
          def change_role_branch(var, from, to, &block)
            from_call, to_call = var.role_as(from), var.change_role(to)
            if block_given?
              Expressions::Core::Condition[from_call, to_call, block.call]
            else
              Expressions::Core::Assert[from_call] + to_call
            end
          end
        end

      end
    end
  end
end
