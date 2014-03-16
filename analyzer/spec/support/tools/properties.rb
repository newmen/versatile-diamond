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
        prop(:high_cm, :high_bridge, :cm)

        prop(:bridge_ct, :bridge, :ct)
        prop(:ab_ct, :activated_bridge, :ct)
        prop(:eab_ct, :extra_activated_bridge, :ct)
        prop(:aib_ct, :activated_incoherent_bridge, :ct)
        prop(:hb_ct, :hydrogenated_bridge, :ct)
        prop(:ehb_ct, :extra_hydrogenated_bridge, :ct)
        prop(:hib_ct, :hydrogenated_incoherent_bridge, :ct)
        prop(:ahb_ct, :activated_hydrogenated_bridge, :ct)

        prop(:bridge_cr, :bridge, :cr)
        prop(:ab_cr, :right_activated_bridge, :cr)
        prop(:hb_cr, :right_hydrogenated_bridge, :cr)
        prop(:ib_cr, :right_incoherent_bridge, :cr)
        prop(:clb_cr, :right_chlorigenated_bridge, :cr)

        prop(:dimer_cr, :dimer, :cr)
        prop(:dimer_cl, :dimer, :cl)
        prop(:ad_cr, :activated_dimer, :cr)

      end
    end
  end
end
