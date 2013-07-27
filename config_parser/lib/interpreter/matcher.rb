module VersatileDiamond
  module Interpreter

    # Matcher class is intended for matching special entities from analyzing file
    class Matcher

      # active bond always defined as star (*)
      ACTIVE_BOND = /\*/

      # atom named like as in periodic table plus some number
      # (it may be valence of atom or something else)
      ATOM_NAME = /[A-Z][a-z]{0,3}[0-9]*/

      # spec name always begins with a lowercase letter and can contain
      # lowercase letters, numbers and "_" symbol
      SPEC_NAME = /[a-z][a-z0-9_]*/

      # options it's all that in brackets
      OPTIONS = /[^\)]+?/

      class << self
        class << self
        private
          # The method is designed to define singleton method that return
          # matching result
          #
          # @param [Symbol] method_name the name of defining method
          # @param [Array] *keys then names of keys in returned hash
          # @yield describes regexp that uses for matching
          def define_match(method_name, *keys, &block)
            keys = nil if keys.empty?

            # Matching method
            # @param [String] str string which will be matched
            # @return [String] correspond matching value when keys is empty
            # @return [Array] with elements ordered by passed keys
            # @return [nil] if passed to defined method string is not matched
            define_method(method_name) do |str|
              m = block.call.match(str)
              m && ((!keys && m[0]) || (keys && keys.map { |key| m[key] }))
            end
          end
        end

        # Matches active bonds
        define_match :active_bond do
          /\A#{ACTIVE_BOND}\Z/
        end

        # Matches atoms by atom name
        define_match :atom do
          /\A#{ATOM_NAME}\Z/
        end

        # Matches atoms specified by lattice
        define_match :specified_atom, :atom, :lattice do
          /\A(?<atom>#{ATOM_NAME})(?:%(?<lattice>\S+))\Z/
        end

        # Matches atoms used in some specie and passed as keyname in brackets
        define_match :used_atom, :spec, :atom do
          /\A(?<spec>#{SPEC_NAME})\(\s*:(?<atom>[a-z][a-z0-9_]*)\s*\)\Z/
        end

        # Matches species specified by options passed in brackets if they exists
        define_match :specified_spec, :spec, :options do
          /\A(?<spec>#{SPEC_NAME})(?:\(\s*(?<options>#{OPTIONS})\s*\))?\Z/
        end

        # Matches equations of two types: typical and ubiquitous
        def equation(str)
          term = /(#{ACTIVE_BOND}|#{ATOM_NAME}|#{SPEC_NAME}(?:\(#{OPTIONS}\))?)/
          side = /\A(?:#{term}\s*\+)?\s*#{term}\Z/
          matches = str.split(/\s*=\s*/).map do |one_side|
            side.match(one_side)
          end
          matches.compact!

          matches.size == 2 ?
            matches.map(&:to_a).each(&:shift).map(&:compact) :
            nil
        end
      end
    end

  end
end
