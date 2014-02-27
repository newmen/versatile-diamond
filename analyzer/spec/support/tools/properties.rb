require_relative '../concepts/handbook'

module VersatileDiamond
  module Tools
    module Support

      # Provides atom properties instances for RSpec
      module Properties
        include Tools::Handbook

        def self.prop(propname, specname, keyname)
          set(propname) do
            spec = send(specname)
            AtomProperties.new(spec, spec.atom(keyname))
          end
        end

        prop(:methyl, :unfixed_methyl_on_bridge, :cm)
        prop(:c2b, :high_bridge, :cm)

        prop(:bridge_ct, :bridge, :ct)
        prop(:bridge_cr, :bridge, :cr)
        prop(:dimer_cr, :dimer, :cr)
        prop(:dimer_cl, :dimer, :cl)

        prop(:ad_cr, :activated_dimer, :cr)
        prop(:ab_ct, :activated_bridge, :ct)
        prop(:aib_ct, :activated_incoherent_bridge, :ct)
        prop(:eab_ct, :extra_activated_bridge, :ct)

      end
    end
  end
end
