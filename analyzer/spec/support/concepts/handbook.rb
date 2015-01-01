module VersatileDiamond
  module Concepts
    module Support

      # Provides concept instances for RSpec
      module Handbook
        include Tools::Handbook

        # Lattices:
        set(:diamond) { Lattice.new(:d, 'Diamond') }

        # Atoms:
        set(:h) { Atom.hydrogen }
        set(:cl) { Atom.new('Cl', 1) }
        set(:o) { Atom.new('O', 2) }
        set(:n) { Atom.new('N', 3) }
        set(:c) { Atom.new('C', 4) }
        set(:cd) do
          d = c.dup
          d.lattice = diamond; d
        end

        # Specific atoms:
        %w(h n c c0 cd).each do |name|
          set(:"activated_#{name}") do
            SpecificAtom.new(send(name), options: [active_bond])
          end
        end
        set(:extra_activated_c) do
          a = activated_c.dup
          a.active!; a
        end
        set(:extra_activated_cd) do
          a = activated_cd.dup
          a.active!; a
        end
        set(:activated_incoherent_cd) do
          a = activated_cd.dup
          a.incoherent!; a
        end
        set(:incoherent_c) { SpecificAtom.new(c, options: [incoherent]) }
        set(:incoherent_activated_c) do
          SpecificAtom.new(c, options: [incoherent, active_bond])
        end
        set(:incoherent_c_hydride) do
          SpecificAtom.new(c, options: [incoherent], monovalents: [adsorbed_h])
        end
        set(:incoherent_cd) { SpecificAtom.new(cd, options: [incoherent]) }
        set(:incoherent_activated_cd) do
          SpecificAtom.new(cd, options: [incoherent, active_bond])
        end
        set(:unfixed_c) { SpecificAtom.new(c, options: [unfixed]) }
        set(:unfixed_activated_c) do
          SpecificAtom.new(c, options: [unfixed, active_bond])
        end

        set(:c_hydride) { SpecificAtom.new(c, monovalents: [adsorbed_h]) }
        set(:cd_chloride) { SpecificAtom.new(cd, monovalents: [adsorbed_cl]) }
        set(:cd_hydride) { SpecificAtom.new(cd, monovalents: [adsorbed_h]) }
        set(:cd_extra_hydride) { SpecificAtom.new(cd, monovalents: [adsorbed_h] * 2) }
        set(:activated_cd_hydride) do
          SpecificAtom.new(cd, options: [active_bond], monovalents: [adsorbed_h])
        end
        set(:incoherent_cd_hydride) do
          SpecificAtom.new(cd, options: [incoherent], monovalents: [adsorbed_h])
        end

        # Few atoms for different cases
        3.times do |i|
          set(:"c#{i}") { c.dup }
          set(:"cd#{i}") { cd.dup }
          set(:"activated_cd#{i}") { activated_cd.dup }
        end

        # Relation parameters, bonds and positions:
        set(:param_amorph) { Bond::AMORPH_PARAMS }
        set(:free_bond) { Bond.amorph }
        [:front, :cross].each do |dir|
          [100, 110].each do |face|
            param_hash = { face: face, dir: dir }
            set(:"param_#{face}_#{dir}") { param_hash }
            set(:"bond_#{face}_#{dir}") { Bond[param_hash] }
            set(:"position_#{face}_#{dir}") { Position[param_hash] }
          end
        end

        set(:position_duplicate) { Position::Duplicate }
        set(:unspecified_atoms) { Position::UnspecifiedAtoms }
        set(:undefined_relation) do
          VersatileDiamond::Lattices::Base::UndefinedRelation
        end

        # Specs and specific specs:
        set(:hydrogen_base) { GasSpec.new(:hydrogen, h: h) }
        set(:hydrogen) { SpecificSpec.new(hydrogen_base) }
        set(:hydrogen_ion) { SpecificSpec.new(hydrogen_base, h: activated_h) }

        set(:methane_base) { GasSpec.new(:methane, c: c) }
        set(:methane) { SpecificSpec.new(methane_base) }
        set(:methyl) { SpecificSpec.new(methane_base, c: activated_c) }

        set(:ethylene_base) do
          s = GasSpec.new(:ethylene, c1: c1, c2: c2)
          s.link(c1, c2, free_bond)
          s.link(c1, c2, free_bond); s
        end
        set(:vinyl) { SpecificSpec.new(ethylene_base, c1: activated_c) }

        set(:bridge_base) do
          s = DuppableSurfaceSpec.new(:bridge, ct: cd)
          cl, cr = AtomReference.new(s, :ct), AtomReference.new(s, :ct)
          s.describe_atom(:cl, cl)
          s.describe_atom(:cr, cr)
          s.link(cd, cl, bond_110_cross)
          s.link(cd, cr, bond_110_cross); s
        end
        set(:bridge_base_dup) do
          bridge_base.dup(:bridge_dup, [[:ct, :t], [:cr, :r], [:cl, :l]])
        end

        set(:bridge) { SpecificSpec.new(bridge_base) }
        set(:activated_bridge) { SpecificSpec.new(bridge_base, ct: activated_cd) }
        set(:hydrogenated_bridge) { SpecificSpec.new(bridge_base, ct: cd_hydride) }
        set(:activated_hydrogenated_bridge) do
          SpecificSpec.new(bridge_base, ct: activated_cd_hydride)
        end
        set(:activated_incoherent_bridge) do
          SpecificSpec.new(bridge_base, ct: activated_incoherent_cd)
        end
        set(:hydrogenated_incoherent_bridge) do
          SpecificSpec.new(bridge_base, ct: incoherent_cd_hydride)
        end
        set(:extra_activated_bridge) do
          SpecificSpec.new(bridge_base, ct: extra_activated_cd)
        end
        set(:extra_hydrogenated_bridge) do
          SpecificSpec.new(bridge_base, ct: cd_extra_hydride)
        end
        set(:chlorigenated_bridge) do
          SpecificSpec.new(bridge_base, ct: cd_chloride)
        end
        set(:right_activated_bridge) do
          a = SpecificAtom.new(bridge_base.atom(:cr), options: [active_bond])
          SpecificSpec.new(bridge_base, cr: a)
        end
        set(:right_incoherent_bridge) do
          a = SpecificAtom.new(bridge_base.atom(:cr), options: [incoherent])
          SpecificSpec.new(bridge_base, cr: a)
        end
        set(:right_hydrogenated_bridge) do
          a = SpecificAtom.new(bridge_base.atom(:cr), monovalents: [adsorbed_h])
          SpecificSpec.new(bridge_base, cr: a)
        end
        set(:right_chlorigenated_bridge) do
          a = SpecificAtom.new(bridge_base.atom(:cr), monovalents: [adsorbed_cl])
          SpecificSpec.new(bridge_base, cr: a)
        end
        set(:extended_bridge_base) { bridge_base.extend_by_references }
        set(:right_activated_extended_bridge) do
          right_activated_bridge.extended
        end

        set(:half_extended_bridge_base) do
          s = SurfaceSpec.new(:half_extended_bridge)
          s.adsorb(bridge_base)
          s.rename_atom(:cr, :cbr)
          s.rename_atom(:cl, :cbl)
          s.rename_atom(:ct, :cr)
          s.describe_atom(:ct, cd.dup)
          s.describe_atom(:cl, AtomReference.new(bridge_base, :ct))
          s.link(s.atom(:ct), s.atom(:cr), bond_110_cross)
          s.link(s.atom(:ct), s.atom(:cl), bond_110_cross); s
        end

        set(:methyl_on_bridge_base) do
          s = DuppableSurfaceSpec.new(:methyl_on_bridge, cm: c)
          s.adsorb(bridge_base)
          s.rename_atom(:ct, :cb)
          s.link(c, s.atom(:cb), free_bond); s
        end
        set(:methyl_on_bridge_base_dup) do
          methyl_on_bridge_base.dup(:methyl_on_bridge_dup,
            [[:cm, :m], [:ct, :b], [:cr, :r], [:cl, :l]])
        end
        set(:methyl_on_bridge) { SpecificSpec.new(methyl_on_bridge_base) }
        set(:activated_methyl_on_bridge) do
          SpecificSpec.new(methyl_on_bridge_base, cm: activated_c)
        end
        set(:extra_activated_methyl_on_bridge) do
          SpecificSpec.new(methyl_on_bridge_base, cm: extra_activated_c)
        end
        set(:methyl_on_activated_bridge) do
          SpecificSpec.new(methyl_on_bridge_base, cb: activated_cd)
        end
        set(:methyl_on_incoherent_bridge) do
          SpecificSpec.new(methyl_on_bridge_base, cb: incoherent_cd)
        end
        set(:activated_methyl_on_incoherent_bridge) do
          SpecificSpec.new(
            methyl_on_bridge_base, cm: activated_c, cb: incoherent_cd)
        end
        set(:unfixed_methyl_on_bridge) do
          SpecificSpec.new(methyl_on_bridge_base, cm: unfixed_c)
        end
        set(:incoherent_methyl_on_bridge) do
          SpecificSpec.new(methyl_on_bridge_base, cm: incoherent_c)
        end
        set(:incoherent_activated_methyl_on_bridge) do
          SpecificSpec.new(methyl_on_bridge_base, cm: incoherent_activated_c)
        end
        set(:incoherent_hydrogenated_methyl_on_bridge) do
          SpecificSpec.new(methyl_on_bridge_base, cm: incoherent_c_hydride)
        end
        set(:unfixed_activated_methyl_on_incoherent_bridge) do
          SpecificSpec.new(methyl_on_bridge_base,
            cm: unfixed_activated_c, cb: incoherent_cd)
        end
        set(:methyl_on_extended_bridge_base) do
          methyl_on_bridge_base.extend_by_references
        end
        set(:activated_methyl_on_extended_bridge) do
          activated_methyl_on_bridge.extended
        end

        set(:methyl_on_half_extended_bridge_base) do
          s = SurfaceSpec.new(:methyl_on_half_extended_bridge, cm: c.dup)
          s.adsorb(half_extended_bridge_base)
          s.link(s.atom(:ct), s.atom(:cm), free_bond); s
        end

        set(:methyl_on_right_bridge_base) do
          s = SurfaceSpec.new(:methyl_on_right_bridge, cm: c)
          s.adsorb(bridge_base)
          s.link(c, s.atom(:cr), free_bond); s
        end
        # set(:methyl_on_right_bridge) { SpecificSpec.new(methyl_on_right_bridge_base) }
        set(:activated_methyl_on_right_bridge) do
          SpecificSpec.new(methyl_on_right_bridge_base, cm: activated_c)
        end

        set(:ethane_on_bridge_base) do
          s = SurfaceSpec.new(:ethane_on_bridge, c2: c.dup)
          s.adsorb(methyl_on_bridge_base)
          s.rename_atom(:cm, :c1)
          s.link(s.atom(:c1), s.atom(:c2), free_bond); s
        end

        set(:vinyl_on_bridge_base) do
          s = SurfaceSpec.new(:vinyl_on_bridge)
          s.adsorb(ethane_on_bridge_base)
          s.link(s.atom(:c1), s.atom(:c2), free_bond); s
        end

        set(:high_bridge_base) do
          s = SurfaceSpec.new(:high_bridge)
          s.adsorb(methyl_on_bridge_base)
          s.link(s.atom(:cm), s.atom(:cb), free_bond); s
        end
        set(:high_bridge) { SpecificSpec.new(high_bridge_base) }

        set(:dimer_base) do
          s = DuppableSurfaceSpec.new(:dimer)
          s.adsorb(bridge_base)
          s.rename_atom(:cl, :crb)
          s.rename_atom(:ct, :cr)
          s.adsorb(bridge_base)
          s.rename_atom(:cl, :clb)
          s.rename_atom(:ct, :cl)
          s.link(s.atom(:cr), s.atom(:cl), bond_100_front); s
        end
        set(:dimer_base_dup) do
          dimer_base.dup(:dimer_dup, [[:cr, :r], [:cl, :l]])
        end

        set(:dimer) { SpecificSpec.new(dimer_base) }
        set(:activated_dimer) { SpecificSpec.new(dimer_base, cr: activated_cd) }
        set(:twise_incoherent_dimer) do
          SpecificSpec.new(dimer_base, cr: incoherent_cd.dup, cl: incoherent_cd.dup)
        end
        set(:activated_incoherent_dimer) do
          SpecificSpec.new(dimer_base, cr: incoherent_cd, cl: activated_cd)
        end
        set(:bottom_hydrogenated_activated_dimer) do
          SpecificSpec.new(dimer_base, cr: activated_cd, clb: cd_hydride)
        end
        set(:right_bottom_hydrogenated_activated_dimer) do
          SpecificSpec.new(dimer_base, cr: activated_cd, crb: cd_hydride)
        end
        set(:extended_dimer_base) { dimer_base.extend_by_references }
        set(:extended_dimer) { dimer.extended }

        set(:horizont_extended_dimer_base) do
          s = SurfaceSpec.new(:horizont_extended_dimer, crr: cd.dup)
          s.adsorb(bridge_base)
          s.rename_atom(:cl, :clhb)
          s.rename_atom(:ct, :clht)
          s.rename_atom(:cr, :crb)
          s.adsorb(bridge_base)
          s.rename_atom(:cl, :crhb)
          s.rename_atom(:ct, :crht)
          s.rename_atom(:cr, :_cr0)
          s.adsorb(bridge_base)
          s.rename_atom(:ct, :cl)
          s.rename_atom(:crr, :cr)
          s.link(s.atom(:_cr0), s.atom(:cr), bond_110_front)
          s.link(s.atom(:crb), s.atom(:cr), bond_110_front)
          s.link(s.atom(:cl), s.atom(:cr), bond_100_front); s
        end
        set(:horizont_extended_dimer) do
          SpecificSpec.new(horizont_extended_dimer_base)
        end

        set(:pseudo_dimer_base) do
          b = bridge_base
          r, l = AtomReference.new(b, :ct), AtomReference.new(b, :ct)
          s = SurfaceSpec.new(:pseudo_dimer, cl: l, cr: r)
          s.link(r, l, bond_100_front); s
        end

        set(:methyl_on_dimer_base) do
          s = SurfaceSpec.new(:methyl_on_dimer, cm: c)
          s.adsorb(dimer_base)
          s.link(s.atom(:cr), s.atom(:cm), free_bond); s
        end
        set(:methyl_on_dimer) { SpecificSpec.new(methyl_on_dimer_base) }
        set(:activated_methyl_on_dimer) do
          SpecificSpec.new(methyl_on_dimer_base, cm: activated_c)
        end
        set(:activated_dimer_in_methyl_on_dimer) do
          SpecificSpec.new(methyl_on_dimer_base, cl: activated_cd)
        end

        set(:two_methyls_on_dimer_base) do
          s = SurfaceSpec.new(:two_methyls_on_dimer, c2: c.dup)
          s.adsorb(methyl_on_dimer_base)
          s.rename_atom(:cm, :c1)
          s.link(s.atom(:cl), s.atom(:c2), free_bond); s
        end

        set(:vinyl_on_dimer_base) do
          s = SurfaceSpec.new(:vinyl_on_dimer)
          s.adsorb(ethane_on_bridge_base)
          s.rename_atom(:cb, :cl)
          s.adsorb(bridge_base)
          s.rename_atom(:ct, :cl)
          s.link(s.atom(:cl), s.atom(:cr), bond_100_front)
          s.link(s.atom(:c1), s.atom(:c2), free_bond); s
        end

        set(:three_bridges_base) do
          s = SurfaceSpec.new(:three_bridges, tt: cd.dup)
          s.adsorb(bridge_base)
          s.rename_atom(:ct, :_ct0)
          s.rename_atom(:cl, :_cl0)
          s.rename_atom(:cr, :cc)
          s.adsorb(bridge_base)
          s.link(s.atom(:tt), s.atom(:cc), bond_110_cross)
          s.link(s.atom(:tt), s.atom(:ct), bond_110_cross); s
        end

        set(:bridge_with_dimer_base) do
          s = SurfaceSpec.new(:bridge_with_dimer, tt: cd.dup)
          s.adsorb(dimer_base)
          s.adsorb(bridge_base)
          s.link(s.atom(:tt), s.atom(:cr), bond_110_cross)
          s.link(s.atom(:tt), s.atom(:ct), bond_110_cross); s
        end

        set(:cross_bridge_on_bridges_base) do
          s = SurfaceSpec.new(:cross_bridge_on_bridges)
          s.adsorb(bridge_base)
          s.rename_atom(:ct, :ctl)
          s.adsorb(methyl_on_bridge_base)
          s.rename_atom(:cb, :ctr)
          s.link(s.atom(:ctl), s.atom(:ctr), position_100_cross)
          s.link(s.atom(:cm), s.atom(:ctl), free_bond); s
        end
        set(:cross_bridge_on_bridges) do
          SpecificSpec.new(cross_bridge_on_bridges_base)
        end

        set(:cross_bridge_on_dimers_base) do
          s = SurfaceSpec.new(:cross_bridge_on_dimers)
          s.adsorb(dimer_base)
          s.rename_atom(:cl, :csl)
          s.rename_atom(:cr, :ctl)
          s.adsorb(methyl_on_dimer_base)
          s.rename_atom(:cl, :csr)
          s.rename_atom(:cr, :ctr)
          s.link(s.atom(:csl), s.atom(:csr), position_100_cross)
          s.link(s.atom(:ctl), s.atom(:ctr), position_100_cross)
          s.link(s.atom(:cm), s.atom(:ctl), free_bond); s
        end

        set(:intermed_migr_down_bridge_base) do
          s = SurfaceSpec.new(:intermed_migr_down_bridge)
          s.adsorb(methyl_on_bridge_base)
          s.rename_atom(:cl, :cbl)
          s.rename_atom(:cr, :cbr)
          s.adsorb(bridge_base)
          s.rename_atom(:ct, :cbt)
          s.link(s.atom(:cbt), s.atom(:cbr), position_100_cross)
          s.link(s.atom(:cm), s.atom(:cbt), free_bond); s
        end
        set(:intermed_migr_down_bridge) do
          SpecificSpec.new(intermed_migr_down_bridge_base)
        end

        set(:intermed_migr_down_half_base) do
          s = SurfaceSpec.new(:intermed_migr_down_half)
          s.adsorb(dimer_base)
          s.rename_atom(:cl, :cdl)
          s.rename_atom(:cr, :cdr)
          s.adsorb(methyl_on_bridge_base)
          s.rename_atom(:cl, :cbl)
          s.rename_atom(:cr, :cbr)
          s.link(s.atom(:cdr), s.atom(:cbr), position_100_cross)
          s.link(s.atom(:cm), s.atom(:cdr), free_bond); s
        end
        set(:intermed_migr_down_half) do
          SpecificSpec.new(intermed_migr_down_half_base)
        end

        set(:intermed_migr_down_full_base) do
          s = SurfaceSpec.new(:intermed_migr_down_full)
          s.adsorb(intermed_migr_down_half_base)
          s.link(s.atom(:cdl), s.atom(:cbl), position_100_cross); s
        end
        set(:intermed_migr_down_full) do
          SpecificSpec.new(intermed_migr_down_full_base)
        end

        set(:intermed_migr_down_mod_base) do
          s = SurfaceSpec.new(:intermed_migr_down_mod, cdm: c)
          s.adsorb(intermed_migr_down_half_base)
          s.link(s.atom(:cdl), s.atom(:cdm), free_bond); s
        end
        set(:intermed_migr_down_mod) do
          SpecificSpec.new(intermed_migr_down_mod_base)
        end

        # Relevant states:
        set(:incoherent) { Incoherent.property }
        set(:unfixed) { Unfixed.property }

        # Active bond:
        set(:active_bond) { ActiveBond.property }

        # Atomic specs:
        set(:adsorbed_h) { AtomicSpec.new(h) }
        set(:adsorbed_cl) { AtomicSpec.new(cl) }

        # Ubiquitous reactions:
        set(:sd_source) { [active_bond, hydrogen_ion] }
        set(:sd_product) { [adsorbed_h] }
        set(:surface_deactivation) do
          UbiquitousReaction.new(
            :forward, 'surface deactivation', sd_source, sd_product)
        end

        set(:sa_source) { [adsorbed_h, hydrogen_ion] }
        set(:sa_product) { [active_bond, hydrogen] }
        set(:surface_activation) do
          UbiquitousReaction.new(
            :forward, 'surface activation', sa_source, sa_product)
        end

        # Reactions:
        set(:ma_source) { [methyl_on_bridge.dup, hydrogen_ion] }
        set(:ma_products) { [activated_methyl_on_bridge.dup, hydrogen] }
        set(:ma_names_to_specs) do {
          source: [[:mob, ma_source.first], [:h, hydrogen_ion]],
          products: [[:mob, ma_products.first], [:h, hydrogen]]
        } end
        set(:ma_atom_map) do
          Mcs::AtomMapper.map(ma_source, ma_products, ma_names_to_specs)
        end
        set(:methyl_activation) do
          Reaction.new(
            :forward, 'methyl activation', ma_source, ma_products, ma_atom_map)
        end

        set(:dm_source) { [activated_methyl_on_bridge.dup, hydrogen_ion] }
        set(:dm_product) { [methyl_on_bridge.dup] }
        set(:dm_names_to_specs) do {
          source: [[:mob, dm_source.first], [:h, hydrogen_ion]],
          products: [[:mob, dm_product.first]]
        } end
        set(:dm_atom_map) do
          Mcs::AtomMapper.map(dm_source, dm_product, dm_names_to_specs)
        end
        set(:methyl_deactivation) do
          Reaction.new(:forward,
            'methyl deactivation', dm_source, dm_product, dm_atom_map)
        end

        set(:am_source) { [methyl, activated_bridge.dup] }
        set(:am_products) { [methyl_on_bridge.dup] }
        set(:am_names_to_specs) do {
          source: [[:m, methyl], [:b, am_source.last]],
          products: [[:mob, am_products.first]]
        } end
        set(:am_atom_map) do
          Mcs::AtomMapper.map(am_source, am_products, am_names_to_specs)
        end
        set(:methyl_adsorption) do
          Reaction.new(
            :forward, 'methyl adsorption', am_source, am_products, am_atom_map)
        end

        set(:md_source) { [methyl_on_bridge.dup, hydrogen_ion] }
        set(:md_products) { [methane, activated_bridge.dup] }
        set(:md_names_to_specs) do {
          source: [[:mob, md_source.first]],
          products: [[:m, methane], [:b, md_products.last]]
        } end
        set(:md_atom_map) do
          Mcs::AtomMapper.map(md_source, md_products, md_names_to_specs)
        end
        set(:methyl_desorption) do
          Reaction.new(
            :forward, 'methyl desorption', md_source, md_products, md_atom_map)
        end

        set(:hm_source) { [methyl_on_dimer.dup, activated_dimer.dup] }
        set(:hm_products) { [activated_methyl_on_dimer.dup, dimer.dup] }
        set(:hm_names_to_specs) do {
          source: [[:mod, hm_source.first], [:d, hm_source.last]],
          products: [[:mod, hm_products.first], [:d, hm_products.last]]
        } end
        set(:hm_atom_map) do
          Mcs::AtomMapper.map(hm_source, hm_products, hm_names_to_specs)
        end
        set(:hydrogen_migration) do
          r = Reaction.new(:forward, 'hydrogen migration',
            hm_source, hm_products, hm_atom_map)
          from = [hm_source.first, hm_source.first.atom(:cr)]
          to = [hm_source.last, hm_source.last.atom(:cr)]
          r.position_between(from, to, position_100_front); r
        end

        set(:df_source) { [activated_bridge.dup, activated_incoherent_bridge.dup] }
        set(:df_products) { [dimer.dup] }
        set(:df_names_to_specs) do {
          source: [[:b1, df_source.first], [:b2, df_source.last]],
          products: [[:d, df_products.first]]
        } end
        set(:df_atom_map) do
          Mcs::AtomMapper.map(df_source, df_products, df_names_to_specs)
        end
        set(:dimer_formation) do
          Reaction.new(:forward, 'dimer formation',
            df_source, df_products, df_atom_map)
        end

        set(:crm_source) { [cross_bridge_on_bridges.dup] }
        set(:crm_products) { [activated_methyl_on_bridge.dup, activated_bridge.dup] }
        set(:crm_names_to_specs) do {
          source: [[:cbobs, crm_source.first]],
          products: [[:amob, crm_products.first], [:ab, crm_products.last]]
        } end
        set(:crm_atom_map) do
          Mcs::AtomMapper.map(crm_source, crm_products, crm_names_to_specs)
        end
        set(:sierpinski_drop) do
          Reaction.new(:forward, 'sierpinski drop',
            crm_source, crm_products, crm_atom_map)
        end

        set(:ah_source) do
          [right_hydrogenated_bridge.dup, right_hydrogenated_bridge.dup]
        end
        set(:ah_products) do
          [right_activated_bridge.dup, hydrogen, right_activated_bridge.dup]
        end
        set(:ah_names_to_specs) do {
          source: [[:br1, ah_source.first], [:br2, ah_source.last]],
          products: [
            [:br1, ah_products.first], [:br2, ah_products.last], [:h, hydrogen]
          ]
        } end
        set(:ah_atom_map) do
          Mcs::AtomMapper.map(ah_source, ah_products, ah_names_to_specs)
        end
        set(:hydrogen_abs_from_gap) do
          r = Reaction.new(:forward, 'hydrogen abs from gap',
            ah_source, ah_products, ah_atom_map)
          from = [ah_source.first, ah_source.first.atom(:cr)]
          to = [ah_source.last, ah_source.last.atom(:cr)]
          r.position_between(from, to, position_100_front); r
        end

        set(:imdhf_source) { [activated_bridge.dup, activated_methyl_on_dimer.dup] }
        set(:imdhf_products) { [intermed_migr_down_half.dup] }
        set(:imdhf_names_to_specs) do {
          source: [[:ab, imdhf_source.first], [:amod, imdhf_source.last]],
          products: [:imdh, imdhf_products.first]
        } end
        set(:imdhf_atom_map) do
          Mcs::AtomMapper.map(imdhf_source, imdhf_products, imdhf_names_to_specs)
        end
        set(:intermed_migr_dh_formation) do
          r = Reaction.new(:forward, 'intermed migr dh formation',
            imdhf_source, imdhf_products, imdhf_atom_map)
        end

        set(:imdff_source) { [activated_bridge.dup, activated_methyl_on_dimer.dup] }
        set(:imdff_products) { [intermed_migr_down_full.dup] }
        set(:imdff_names_to_specs) do {
          source: [[:ab, imdff_source.first], [:amod, imdff_source.last]],
          products: [:imdf, imdff_products.first]
        } end
        set(:imdff_atom_map) do
          Mcs::AtomMapper.map(imdff_source, imdff_products, imdff_names_to_specs)
        end
        set(:intermed_migr_df_formation) do
          r = Reaction.new(:forward, 'intermed migr df formation',
            imdff_source, imdff_products, imdff_atom_map)
        end

        set(:immod_source) do
          [activated_methyl_on_bridge.dup, activated_dimer_in_methyl_on_dimer.dup]
        end
        set(:immod_products) { [intermed_migr_down_mod.dup] }
        set(:immod_names_to_specs) do {
          source: [[:amob, immod_source.first], [:adimod, immod_source.last]],
          products: [:imdmod, immod_products.first]
        } end
        set(:immod_atom_map) do
          Mcs::AtomMapper.map(immod_source, immod_products, immod_names_to_specs)
        end
        set(:intermed_migr_dmod_formation) do
          r = Reaction.new(:forward, 'intermed migr dmod formation',
            immod_source, immod_products, immod_atom_map)
        end

        set(:mi_source) do
          [activated_methyl_on_extended_bridge.dup, activated_dimer.dup]
        end
        set(:mi_product) { [extended_dimer.dup] }
        set(:mi_names_to_specs) do {
          source: [[:mob, mi_source.first], [:d, mi_source.last]],
          products: [[:ed, mi_product.first]]
        } end
        set(:mi_atom_map) do
          Mcs::AtomMapper.map(mi_source, mi_product, mi_names_to_specs)
        end
        set(:methyl_incorporation) do
          Reaction.new(:forward, 'methyl incorporation',
            mi_source, mi_product, mi_atom_map)
        end

        set(:mg_source) do
          [
            extra_activated_methyl_on_bridge.dup,
            right_activated_bridge.dup,
            right_activated_bridge.dup
          ]
        end
        set(:mg_product) { [horizont_extended_dimer.dup] }
        set(:mg_names_to_specs) do {
          source: [
            [:mob, mg_source.first], [:br1, mg_source[1]], [:br2, mg_source[2]]
          ],
          products: [[:hed, mg_product.first]]
        } end
        set(:mg_atom_map) do
          Mcs::AtomMapper.map(mg_source, mg_product, mg_names_to_specs)
        end
        set(:methyl_to_gap) do
          Reaction.new(:forward, 'methyl to gap', mg_source, mg_product, mg_atom_map)
        end

        # Environments (targeted to dimer formation reverse reaction):
        set(:dimers_row) do
          Environment.new(:dimers_row, targets: [:one, :two])
        end
        set(:at_end) do
          w = Where.new(:at_end, 'at end of dimers row', specs: [dimer])
          w.raw_position(:one, [dimer, dimer.atom(:cl)], position_100_cross)
          w.raw_position(:two, [dimer, dimer.atom(:cr)], position_100_cross); w
        end
        set(:on_end) do
          ab = df_source.first
          aib = df_source.last
          at_end.concretize(one: [ab, ab.atom(:ct)], two: [aib, aib.atom(:ct)])
        end

        set(:at_middle) do
          w = Where.new(:at_middle, 'at middle of dimers row', specs: [dimer])
          w.raw_position(:one, [dimer, dimer.atom(:cl)], position_100_cross)
          w.raw_position(:two, [dimer, dimer.atom(:cr)], position_100_cross)
          w.parents << at_end; w
        end
        set(:on_middle) do
          ab = df_source.first
          aib = df_source.last
          at_middle.concretize(one: [ab, ab.atom(:ct)], two: [aib, aib.atom(:ct)])
        end

        set(:end_lateral_df) do
          dimer_formation.lateral_duplicate('end lateral', [on_end])
        end

        set(:middle_lateral_df) do
          dimer_formation.lateral_duplicate('middle lateral', [on_middle])
        end

        set(:near_methyl) do
          mob = methyl_on_bridge
          w = Where.new(:near_methyl, 'chain neighbour methyl', specs: [mob])
          w.raw_position(:target, [mob, mob.atom(:cb)], position_100_front); w
        end
        set(:there_methyl) do
          ab = df_source.first
          near_methyl.concretize(target: [ab, ab.atom(:ct)])
        end
      end

    end
  end
end
