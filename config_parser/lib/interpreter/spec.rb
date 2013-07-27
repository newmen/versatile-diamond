module VersatileDiamond
  module Interpreter

    # The class instance interpret atoms and links between them.
    # When one spec uses an other then atoms and links from another spec coping
    # to original spec.
    # If spec is recursive (i.e. uses itself) then no copy, reference to used
    # atom creates instead.
    class Spec < Component
      include AtomMatcher

      # Stores concept spec as internal property
      # @param [Concepts::Spec] concept_spec the stored concept spec instance
      def initialize(concept_spec)
        @concept = concept_spec
      end

      # Adsorbs atoms and links of aliases and store duplicated atoms hash to
      #   internal variable for future renaming of adsrobed atom keynames
      #
      # @param [Hash] refs the hash which contain alias name as keys and some
      #   another specs as values
      # @raise [Errors::SyntaxError] if alias already adsorbed
      # @raise [Tools::Chest::KeyNameError] if aliased spec cannot be found in
      #   Chest
      def aliases(**refs)
        @aliases_to ||= {}
        refs.each do |alias_name, spec_name|
          spec = Tools::Chest.spec(spec_name)
          duplicates = spec.duplicate_atoms_with_keynames
          original_to_generated = {}
          duplicates.each do |keyname, atom_dup|
            gk = generate_keyname(keyname)
            original_to_generated[keyname] = gk
            @concept.describe_atom(gk, atom_dup)
          end
          @concept.adsorb_links(spec, duplicates)

          @aliases_to[alias_name] = [spec, original_to_generated]
        end
      end

      # Interpret atoms line and store atom instances to concept var
      # @param [Hash] refs hash of describing atoms
      def atoms(**refs)
        refs.each do |keyname, atom_str|
          detect_atom(keyname, atom_str)
        end
      end

      # Bonds atoms together
      # @param [Symbol] first atom keyname
      # @param [Symbol] second atom keyname
      # @param [Hash] options the properties of bond instance
      def bond(*atoms, **options)
        link(*atoms, Concepts::Bond[options])
      end

      # Twise bonds atoms together
      # @param [Symbol] first see at #bond
      # @param [Symbol] second see at #bond
      def dbond(first, second)
        2.times { bond(first, second) }
      end

      # Triple bonds atoms together
      # @param [Symbol] first see at #bond
      # @param [Symbol] second see at #bond
      def tbond(first, second)
        3.times { bond(first, second) }
      end

    private

      # Links atoms together
      # @param [Symbol] first see at #bond
      # @param [Symbol] second see at #bond
      # @param [Concepts::Bond] link_instance the instance of link
      # @yield if given then checks invaild syntax cases
      def link(*atoms, link_instance, &block)
        raise ArgumentError if atoms.size != 2
        first = @concept.atom(atoms[0])
        second = @concept.atom(atoms[1])
        block[first, second] if block_given?
        @concept.link(first, second, link_instance)
      end

      # Detects atom by passed string and store it (or more another) to
      #   concept by keyname
      #
      # @param [Symbol] keyname the keyname of atom in concept
      # @param [String] atom_str the string which described atom
      # @raise [Errors::SyntaxError] if atom cannot be detected
      def detect_atom(keyname, atom_str)
        simple_atom(keyname, atom_str) || used_atom(keyname, atom_str)
      end

      # Detects simple atom by passed string and store to concept by keyname
      # @param [Symbol] keyname see at #detect_atom
      # @param [String] atom_str see at #detect_atom
      # @raise [Tools::Chest::KeyNameError] if atom cannot be finded in Chest
      # @return [Boolean] detected atom or or nil overwise
      def simple_atom(keyname, atom_str)
        if (atom_name = Matcher.atom(atom_str))
          atom = Tools::Chest.atom(atom_name)
          @concept.describe_atom(keyname, atom)
          atom
        else
          nil
        end
      end

      # Detects used atom by passed string and store it (or more another) to
      #   concept by keyname
      #
      # @param [Symbol] keyname see at #detect_atom
      # @param [String] see at #detect_atom
      # @raise [Tools::Chest::KeyNameError] if atom is used in another spec and
      #   it spec cannot be finded in Chest
      # @return [Concepts::AtomReference] if detected atom is ref to same spec
      # @return [Concepts::Atom] detected atom used in another spec
      def used_atom(keyname, atom_str)
        spec_name, atom_keyname = match_used_atom(atom_str)
        if spec_name == @concept.name
          @concept.dependent_from << @concept
          atom = Concepts::AtomReference.new(@concept, atom_keyname)
          @concept.describe_atom(keyname, atom)
        elsif @aliases_to && (alias_to = @aliases_to[spec_name])
          @concept.dependent_from << alias_to.first
          @concept.rename_atom(alias_to.last[atom_keyname], keyname)
        else
          # When atom is used in another spec then accumulate each atoms and
          # links from them
          spec = Tools::Chest.spec(spec_name)
          @concept.dependent_from << spec
          duplicates = spec.duplicate_atoms_with_keynames
          duplicates.each do |k, atom|
            nk = (k == atom_keyname) ? keyname : generate_keyname(k)
            @concept.describe_atom(nk, atom)
          end
          @concept.adsorb_links(spec, duplicates)
        end
      end

      # Generates the new keyname by original keyname with adding a '_' symbol
      #   before original keyname and append unique (for current concept)
      #   number
      #
      # @param [Symbol] original_keyname the original keyname from which will
      #   be generated new keyname
      # @return [Symbol] generated unique keyname
      def generate_keyname(original_keyname)
        keyname = nil
        i = 0
        begin
          keyname = "_#{original_keyname}#{i}"
          i += 1
        end while (@concept.atom(keyname))
        keyname.to_sym
      end

    end

  end
end
