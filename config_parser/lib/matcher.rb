class Matcher
  class << self
    class << self
    private
      def define_match(*args)
        name = args.shift
        keys = args.empty? ? nil : args

        define_method(name) do |str|
          m = yield.match(str)
          m && ((!keys && m[0]) || (keys && keys.map { |key| m[key] }))
        end
      end
    end

    ATOM_NAME = /[A-Z][a-z0-9]*/
    SPEC_NAME = /[a-z][a-z0-9_]*/

    define_match :atom do
      /\A#{ATOM_NAME}\Z/
    end

    define_match :specified_atom, :atom, :lattice do
      /\A(?<atom>#{ATOM_NAME})%(?<lattice>\S+)\Z/
    end

    define_match :used_atom, :spec, :atom do
      /\A(?<spec>#{SPEC_NAME})\(\s*:(?<atom>[a-z][a-z0-9_]*)\s*\)\Z/
    end

    define_match :specified_spec, :spec, :options do
      /\A(?<spec>#{SPEC_NAME})(?:\((?<options>[^\(]+)\))?\Z/
    end
  end
end