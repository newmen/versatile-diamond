module VersatileDiamond
  module Interpreter
    module Support

      # Provides interpreter instances for RSpec
      module Handbook
        include Tools::Handbook

        # Errors:
        set(:syntax_error) { Errors::SyntaxError }

        # Interpreters
        set(:dimensions) { Dimensions.new }
        set(:elements) { Elements.new }
        set(:gas) { Gas.new }
        set(:surface) { Surface.new }
        set(:events) { Events.new }
        set(:reaction) { Reaction.new('reaction name') }

        def interpret_basis
          elements.interpret('atom C, valence: 4')
          gas.interpret('spec :methane')
          gas.interpret('  atoms c: C')
          surface.interpret('lattice :d, cpp_class: Diamond')
          surface.interpret('spec :bridge')
          surface.interpret('  atoms ct: C%d, cl: bridge(:ct), cr: bridge(:ct)')
          surface.interpret('  bond :ct, :cl, face: 110, dir: front')
          surface.interpret('  bond :ct, :cr, face: 110, dir: front')
          surface.interpret('  position :cr, :cl, face: 100, dir: front')
          surface.interpret('spec :methyl_on_bridge')
          surface.interpret('  atoms cb: bridge(:ct), cm: methane(:c)')
          surface.interpret('  bond :cb, :cm')
          surface.interpret('spec :high_bridge')
          surface.interpret('  aliases mob: methyl_on_bridge')
          surface.interpret('  atoms cb: mob(:cb), cm: mob(:cm)')
          surface.interpret('  bond :cb, :cm')
          surface.interpret('spec :dimer')
          surface.interpret('  atoms cl: bridge(:ct), cr: bridge(:ct)')
          surface.interpret('  bond :cl, :cr, face: 100, dir: front')
        end
      end

    end
  end
end