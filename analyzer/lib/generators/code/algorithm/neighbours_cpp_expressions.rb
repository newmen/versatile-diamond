module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains methods for generate cpp expressions which iterates neghbours
        module NeighboursCppExpressions

          # Gets the code which checks relations between current unit and other unit
          # @param [BaseSpecieUnit] other to which relations will be checked
          # @param [Hash] rel_params the parameters of cheking relations
          # @yield should return cpp code string which will be implaced into code
          #   condition block
          # @return [String] the code with checking relations between units
          def check_relations(other, rel_params, &block)
            if latticed?
              other.reverse_check_relations(self, rel_params, &block)
            else
              other.reverse_check_amorph_relations(self, &block)
            end
          end

        protected

          # Gets the code which checks relations between current unit and other unit
          # @param [BaseSpecieUnit] other from which relations will be checked
          # @param [Hash] rel_params the parameters of cheking relations
          # @yield should return cpp code string which will be implaced into code
          #   condition block
          # @return [String] the code with checking relations between units
          def reverse_check_relations(other, rel_params, &block)
            if latticed?
              reverse_check_crystal_relations(other, rel_params, &block)
            else
              reverse_check_amorph_relations(other, &block)
            end
          end

          # Generates code if target atom is latticed
          # @param [BaseSpecieUnit] other from which the relations will be checked
          # @param [Hash] rev_rel_params the parameters of relations from self unit to
          #   other unit
          # @yield should return cpp code string for condition body
          # @return [String] the cpp code with expressions of walking through crystal
          #   lattice
          def reverse_check_crystal_relations(other, rev_rel_params, &block)
            if single? == other.single?
              other.each_nbrs_lambda(atoms, rev_rel_params, &block)
            elsif single?
              other.many_to_one_condition(target_atom, rev_rel_params, &block)
            else # other.single?
              other.one_to_many_condition(atoms, rev_rel_params, &block)
            end
          end

          # Generates code if target atom isn't latticed and other unit isn't multi
          # atomic
          #
          # @param [BaseSpecieUnit] other from which the relation will be checked
          # @yield should return cpp code string for condition body
          # @return [String] the cpp code whith checking current amorphous atom
          def reverse_check_amorph_relations(other, &block)
            if single?
              if latticed?
                raise 'No algorithm implementation for next amorph atom case'
              elsif !other.single?
                raise 'Wrong initial backbone of algorithm'
              else
                other.amorph_nbr_condition(target_atom, &block)
              end
            else
              raise 'No algorithm implementation for next many amorph atoms case'
            end
          end

          # Generates the code for case when to need to find one atom from several
          # atoms by using the properties of crystal lattice
          #
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   nbr the neighbour atom which will be achived through crystal lattice
          # @param [Hash] rel_params the parameters of relations by which the target
          #   neighbour atoms could be achived
          # @yield should return cpp code which will be executed if target atom will
          #   be achived
          # @return [String] the cpp algorithm code
          # TODO: not tested
          def many_to_one_condition(nbr, rel_params, &block)
            unless target_atom.relations_limits[rel_params] == atoms.size
              raise 'Incorrect getting one atom from many'
            end

            namer.assign_next('neighbour', nbr)
            crystal_call_str = crystal_atom_call(rel_params)
            define_nbr_line = define_var_line('Atom *', nbr, crystal_call_str)

            nbr_var_name = namer.name_of(nbr)
            condition_str = "#{nbr_var_name} && #{check_role_condition([nbr])}"

            with_bond = atoms_with_bond(nbr)
            unless with_bond.empty?
              condition_str = append_check_bond_condition(condition_str, with_bond)
            end

            define_nbr_line + code_condition(condition_str, &block)
          end

          # Gets a code with checking all crystal neighbours of target atom along
          # relations with same as passed parameters
          #
          # @param [Array] nbrs the available neighbours of target atom
          # @param [Hash] rel_params the relation parameters through which neighbours
          #   was gotten
          # @yield should return cpp code string for condition body
          # @return [String] the string with cpp code
          def one_to_many_condition(nbrs, rel_params, &block)
            namer.assign('neighbour', nbrs)
            crystal_call_str = crystal_nbrs_call(rel_params)
            define_nbrs_line = define_var_line('auto', nbrs, crystal_call_str)

            nbrs_var_name = namer.name_of(nbrs)
            condition_str = "#{nbrs_var_name}.all() && #{check_role_condition(nbrs)}"

            with_bond = nbrs_with_bond(nbrs)
            unless with_bond.empty?
              condition_str = append_check_bond_condition(condition_str, with_bond)
            end

            define_nbrs_line + code_condition(condition_str, &block)
          end

          # Gets a code with checking amorph neighbour of target atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   nbr the amorph atom which is available from anchor
          # @yield should return cpp code string for condition body
          # @return [String] the string with cpp code
          def amorph_nbr_condition(nbr, &block)
            if namer.name_of(nbr)
              condition_str = check_bond_call(target_atom, nbr)
              code_condition(condition_str, &block)
            else
              namer.assign_next('amorph', nbr)
              amorph_nbr_call = "#{target_atom_var_name}->amorphNeighbour()"
              define_nbr_line = define_var_line('Atom *', nbr, amorph_nbr_call)
              condition_str = check_role_condition([nbr])
              define_nbr_line + code_condition(condition_str, &block)
            end
          end

          # Provides a basic logic for using eachNeighbours method of engine framework
          # @param [Array] nbrs the neighbour atoms to which iteration will do
          # @param [Hash] rel_params the relation parameters through which neighbours
          #   was gotten
          # @yield should return cpp code string of lambda body
          # @return [String] the string with cpp code
          def each_nbrs_lambda(nbrs, rel_params, &block)
            raise 'Incorrect number of neighbour atoms' unless nbrs.size == atoms.size

            namer.assign('neighbour', nbrs)
            define_nbrs_anchors_lines +
              code_lambda(*each_nbrs_call_args(nbrs, rel_params), &block)
          end

        private

          # Gets the arguments for #each_nbrs_lambda internal call
          # @param [Array] nbrs see at #each_nbrs_lambda same argument
          # @param [Hash] rel_params see at #each_nbrs_lambda same argument
          # @return [Array] the array of arguments for each neighbours operation
          def each_nbrs_call_args(nbrs, rel_params)
            method_args = [atoms_var_name, full_relation_name_ref(rel_params)]
            clojure_args = ['&']

            nbrs_var_name = namer.name_of(nbrs)
            method_name = "eachNeighbour"
            if single?
              lambda_arg = "Atom *#{nbrs_var_name}"
            else
              method_name = "#{method_name}s<#{atoms.size}>"
              lambda_arg = "Atom **#{nbrs_var_name}"
            end

            [method_name, method_args, clojure_args, [lambda_arg]]
          end

          # By default doesn't need to define anchor atoms for each crystal neighbours
          # operation
          #
          # @return [String] the empty string
          def define_nbrs_anchors_lines
            ''
          end

          # Gets the code which calls the atom of crystal by calculating coordinates
          # @param [Hash] rel_params the parameters of relations by which the coords
          #   of target atom will be calculated from own atom instances
          # @return [String] the string with cpp code for getting the atom of crystal
          def crystal_atom_call(rel_params)
            frn_method_name = "#{full_relation_name(rel_params)}_at"
            atoms_vars_names_str = atom.map { |a| namer.name_of(a) }.join(', ')
            "#{crystal_call}->atom(#{frn_method_name}(#{atoms_vars_names_str}))"
          end

          # Gets the code which calls the method of crystal which gets neighbours of
          # target atom
          #
          # @param [Hash] rel_params the relations parameters by which the neighbour
          #   atoms will be gotten
          # @return [String] the string wich cpp code
          def crystal_nbrs_call(rel_params)
            srn_method_name = short_relation_name(rel_params)
            "#{crystal_call}->#{srn_method_name}(#{target_atom_var_name})"
          end

          # Gets the list of atoms pairs between which has a relation, where the first
          # item of pair is atom of current node and the second item is passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   nbr the neighbour atom the bond from which to each internal atom will be
          #   checked
          # @return [Array] the list of pairs of bonded atoms
          def atoms_with_bond(nbr)
            atoms.zip([nbr] * atoms.size).select(&method(:check_bond))
          end

          # Selects neighbour atoms which have bond with target atom
          # @param [Array] nbrs the cheking neighbour atoms
          # @return [Array] the list of pairs where between each pair has a bond
          def nbrs_with_bond(nbrs)
            ([target_atom] * nbrs.size).zip(nbrs).select(&method(:check_bond))
          end

          # Selects pairs which has bond between each other
          # @param [Array] pair of two atoms between which the relation will be checked
          # @return [Array] the list of pairs where between each two atoms has a bond
          def check_bond(pair)
            rel = relation_between(*pair)
            rel && rel.bond?
          end

          # Makes code string with checking bond between passed atoms
          # @param [Array] atoms the array with two atoms between which the bond will
          #   be checked
          # @return [String] code with calling check bond function
          def check_bond_call(*atoms)
            first_var, second_var = atoms.map { |atom| namer.name_of(atom) }
            "#{first_var}->hasBondWith(#{second_var})"
          end

          # Gets the short name of relation for get neighbour atoms
          # @param [Hash] rel_params the relation parameters by which short name will
          #   be gotten
          # @return [String] the short name of relation
          def short_relation_name(rel_params)
            "#{rel_params[:dir]}_#{rel_params[:face]}"
          end

          # Gets the full name of relation by atom and relation parameters
          # @param [Hash] rel_params the relation parameters by which full name will be
          #   gotten
          # @return [String] the full name relation
          def full_relation_name(rel_params)
            lattice_code = generator.lattice_class(target_atom.lattice)
            lattice_class_name = lattice_code.class_name
            short_name = short_relation_name(rel_params)
            "#{lattice_class_name}::#{short_name}"
          end

          # Gets the reference to correspond crystal method of engine framework
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom see at #full_relation_name same argument
          # @param [Hash] rel_params see at #full_relation_name same argument
          # @return [String] the reference to relation method
          def full_relation_name_ref(rel_params)
            "&#{full_relation_name(rel_params)}"
          end

          # Gets the cpp code which uses #crystalBy engine framework method for get a
          # crystal by atom
          #
          # @return [String] the string with cpp call
          def crystal_call
            "crystalBy(#{namer.name_of(target_atom)})"
          end

          # Appends condition of checking bond exsistance between each atoms in passed
          # pairs array
          #
          # @param [String] original_condition to which new conditions will be appended
          # @param [Array] pairs of atoms between which bond existatnce will be checked
          # @return [String] the extended condition
          def append_check_bond_condition(original_condition, pairs)
            parts = pairs.each_with_object([]) do |pair, acc|
              relation = relation_between(*pair)
              next unless relation

              cb_call = check_bond_call(*pair)
              if relation.bond?
                acc << cb_call
              else
                any_uses_bond = pair.permutation.any? do |pr|
                  al, bl = pr.map(&:lattice)
                  bond = Concepts::Bond[relation.params]
                  bond = al.opposite_relation(bl, bond) unless pr == pair
                  use_bond?(pr.first, bond)
                end

                acc << "!#{cb_call}" if any_uses_bond
              end
            end

            ([original_condition] + parts).join(' && ')
          end
        end

      end
    end
  end
end
