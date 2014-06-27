require_relative '../concepts/handbook'

module VersatileDiamond
  module Organizers
    module Support

      # Provides atom properties instances for RSpec
      module Properties
        include Tools::Handbook

        # Creates properties of atom with some name by dependent specific specie and
        # atom of it
        #
        # @param [Symbol] propname the name of creating properties
        # @param [Symbol] specname name of specie by atom of which the properties
        #   will be created
        # @param [Symbol] keyname atom keyname by which the target atom will be got
        # @return [Concepts::AtomProperties] the new atom properties
        def self.prop(propname, specname, keyname)
          set(propname) do
            concept = send(specname)
            spec = DependentSpecificSpec.new(concept)
            AtomProperties.new(spec, concept.atom(keyname))
          end
        end

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
        prop(:mod_cr, :methyl_on_dimer, :cr)
        prop(:mob_cb, :methyl_on_right_bridge_base, :cr)

        prop(:pseudo_dimer_cr, :pseudo_dimer_base, :cr)

        prop(:high_cm, :high_bridge, :cm)
        prop(:cm, :methyl_on_bridge_base, :cm)
        prop(:ucm, :unfixed_methyl_on_bridge, :cm)
        prop(:bob, :cross_bridge_on_bridges_base, :cm)
        prop(:eob, :ethane_on_bridge_base, :c1)
        prop(:vob, :vinyl_on_bridge_base, :c1)
      end
    end
  end
end
