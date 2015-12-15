module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains methods for interact with crystal instance
        module CrystalCppExpressions
        private

          # Gets the code which calls the atom of crystal by calculating coordinates
          # @param [Array] atoms from which the target atom will be gotten
          # @param [Hash] rel_params the parameters of relations by which the coords
          #   of target atom will be calculated
          # @return [String] the string with cpp code for getting the atom of crystal
          def crystal_atom_call(atoms, rel_params)
            coords_call = full_relation_call_at(atoms, rel_params)
            "#{crystal_call(atoms.first)}->atom(#{coords_call})"
          end

          # Gets the code which calls the method of crystal which gets neighbours of
          # passed atom
          #
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be used for receive neighbour atoms
          # @param [Hash] rel_params the relations parameters by which the neighbour
          #   atoms will be gotten
          # @return [String] the string wich cpp code
          def crystal_nbrs_call(atom, rel_params)
            srn_method_name = short_relation_name(rel_params)
            "#{crystal_call(atom)}->#{srn_method_name}(#{name_of(atom)})"
          end

          # Gets the short name of relation for get neighbour atoms
          # @param [Hash] rel_params the relation parameters by which short name will
          #   be gotten
          # @return [String] the short name of relation
          def short_relation_name(rel_params)
            "#{rel_params[:dir]}_#{rel_params[:face]}"
          end

          # Gets the full name of relation by atom and relation parameters
          # @param [Concepts::Lattice] lattice for which the relation name will be
          #   combined
          # @param [Hash] rel_params the relation parameters by which full name will be
          #   gotten
          # @return [String] the full name relation
          def full_relation_name(lattice, rel_params)
            lattice_code = generator.lattice_class(lattice)
            short_name = short_relation_name(rel_params)
            "#{lattice_code.class_name}::#{short_name}"
          end

          # Gets the reference to correspond crystal method of engine framework
          # @param [Concepts::Lattice] lattice for which the relation name will be
          #   combined
          # @param [Hash] rel_params see at #full_relation_name same argument
          # @return [String] the reference to relation method
          def full_relation_name_ref(lattice, rel_params)
            "&#{full_relation_name(lattice, rel_params)}"
          end

          # Calls helper method of crystal which calculates coordinates from passed
          # atoms and relation parameters
          #
          # @param [Array] atoms from which the calculation will be occured
          # @param [Hash] rel_params the parameters of relations by which the coords
          #   will be calculated
          # @return [String] the static crystal method call
          def full_relation_call_at(atoms, rel_params)
            atom = atoms.first
            frn_method_name = "#{full_relation_name(atom.lattice, rel_params)}_at"
            atoms_vars_names_str = names_for(atoms).join(', ')
            "#{frn_method_name}(#{atoms_vars_names_str})"
          end

          # Gets the cpp code which uses #crystalBy engine framework method for get a
          # crystal by atom
          #
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which the instance of crystal will be gotten
          # @return [String] the string with cpp call
          def crystal_call(atom)
            "crystalBy(#{name_of(atom)})"
          end
        end

      end
    end
  end
end

