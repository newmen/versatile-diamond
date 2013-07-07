module VersatileDiamond

  class Matcher

    ACTIVE_BOND = /\*/
    ATOM_NAME = /[A-Z][a-z0-9]*/
    SPEC_NAME = /[a-z][a-z0-9_]*/
    OPTIONS = /[^\)]+/

    class << self
      class << self
      private
        def define_match(*args, &block)
          name = args.shift
          keys = args.empty? ? nil : args

          define_method(name) do |str|
            m = block.call.match(str)
            m && ((!keys && m[0]) || (keys && keys.map { |key| m[key] }))
          end
        end
      end

      define_match :active_bond do
        /\A#{ACTIVE_BOND}\Z/
      end

      define_match :atom do
        /\A#{ATOM_NAME}\Z/
      end

      define_match :specified_atom, :atom, :lattice do
        /\A(?<atom>#{ATOM_NAME})(?:%(?<lattice>\S+))\Z/
      end

      define_match :used_atom, :spec, :atom do
        /\A(?<spec>#{SPEC_NAME})\(\s*:(?<atom>[a-z][a-z0-9_]*)\s*\)\Z/
      end

      define_match :specified_spec, :spec, :options do
        /\A(?<spec>#{SPEC_NAME})(?:\((?<options>#{OPTIONS})\))?\Z/
      end

      def equation(str)
        term = /(#{ACTIVE_BOND}|#{ATOM_NAME}|#{SPEC_NAME}(?:\(#{OPTIONS}\))?)/
        side = /(?:#{term}\s*\+)?\s*#{term}/
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
