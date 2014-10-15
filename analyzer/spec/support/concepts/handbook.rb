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
          s = Concepts::SurfaceSpec.new(:ethane_on_bridge, c2: c.dup)
          s.adsorb(methyl_on_bridge_base)
          s.rename_atom(:cm, :c1)
          s.link(s.atom(:c1), s.atom(:c2), free_bond); s
        end

        set(:vinyl_on_bridge_base) do
          s = Concepts::SurfaceSpec.new(:vinyl_on_bridge)
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

        set(:two_methyls_on_dimer_base) do
          s = SurfaceSpec.new(:two_methyls_on_dimer, c2: c.dup)
          s.adsorb(methyl_on_dimer_base)
          s.rename_atom(:cm, :c1)
          s.link(s.atom(:cl), s.atom(:c2), free_bond); s
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

        set(:cross_bridge_on_bridges_base) do
          s = Concepts::SurfaceSpec.new(:cross_bridge_on_bridges)
          s.adsorb(bridge_base)
          s.rename_atom(:ct, :ctl)
          s.adsorb(methyl_on_bridge_base)
          s.rename_atom(:cb, :ctr)
          s.link(s.atom(:ctl), s.atom(:ctr), position_100_cross)
          s.link(s.atom(:cm), s.atom(:ctl), free_bond); s
        end

        set(:cross_bridge_on_dimers_base) do
          s = Concepts::SurfaceSpec.new(:cross_bridge_on_dimers)
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

        set(:abridge_dup) { activated_bridge.dup }
        set(:md_source) { [methyl_on_bridge.dup] }
        set(:md_products) { [methyl, abridge_dup] }
        set(:md_names_to_specs) do {
          source: [[:mob, md_source.first]],
          products: [[:m, methyl], [:b, abridge_dup]]
        } end
        set(:md_atom_map) do
          Mcs::AtomMapper.map(md_source, md_products, md_names_to_specs)
        end
        set(:methyl_desorption) do
          Reaction.new(
            :forward, 'methyl desorption', md_source, md_products, md_atom_map)
        end

        set(:hm_source) { [methyl_on_dimer, activated_dimer] }
        set(:hm_products) { [activated_methyl_on_dimer, dimer] }
        set(:hm_names_to_specs) do {
          source: [[:mod, methyl_on_dimer], [:d, activated_dimer]],
          products: [[:mod, activated_methyl_on_dimer], [:d, dimer]]
        } end
        set(:hm_atom_map) do
          Mcs::AtomMapper.map(hm_source, hm_products, hm_names_to_specs)
        end
        set(:hydrogen_migration) do
          Reaction.new(:forward, 'hydrogen migration',
            hm_source, hm_products, hm_atom_map)
        end

        set(:dimer_dup_ff) { dimer.dup }
        set(:df_source) { [activated_bridge, activated_incoherent_bridge] }
        set(:df_products) { [dimer_dup_ff] }
        set(:df_names_to_specs) do {
          source: [
            [:b1, activated_bridge], [:b2, activated_incoherent_bridge]],
          products: [[:d, dimer_dup_ff]]
        } end
        set(:df_atom_map) do
          Mcs::AtomMapper.map(df_source, df_products, df_names_to_specs)
        end
        set(:dimer_formation) do
          Reaction.new(:forward, 'dimer formation',
            df_source, df_products, df_atom_map)
        end

        set(:mi_source) { [activated_methyl_on_extended_bridge, activated_dimer] }
        set(:mi_product) { [extended_dimer] }
        set(:mi_names_to_specs) do {
          source: [
            [:mob, activated_methyl_on_extended_bridge],
            [:d, activated_dimer]],
          products: [[:ed, extended_dimer]]
        } end
        set(:mi_atom_map) do
          Mcs::AtomMapper.map(mi_source, mi_product, mi_names_to_specs)
        end
        set(:methyl_incorporation) do
          Reaction.new(:forward, 'methyl incorporation',
            mi_source, mi_product, mi_atom_map)
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
          activated_i_bridge = activated_incoherent_bridge
          at_end.concretize(
            one: [activated_bridge, activated_bridge.atom(:ct)],
            two: [activated_i_bridge, activated_i_bridge.atom(:ct)])
        end

        set(:at_middle) do
          w = Where.new(
            :at_middle, 'at middle of dimers row', specs: [dimer])
          w.raw_position(:one, [dimer, dimer.atom(:cl)], position_100_cross)
          w.raw_position(:two, [dimer, dimer.atom(:cr)], position_100_cross)
          w.parents << at_end; w
        end
        set(:on_middle) do
          activated_i_bridge = activated_incoherent_bridge
          at_middle.concretize(
            one: [activated_bridge, activated_bridge.atom(:ct)],
            two: [activated_i_bridge, activated_i_bridge.atom(:ct)])
        end

        set(:end_lateral_df) do
          dimer_formation.lateral_duplicate('end lateral', [on_end])
        end

        set(:middle_lateral_df) do
          dimer_formation.lateral_duplicate('middle lateral', [on_middle])
        end

        set(:near_methyl) do
          w = Where.new(:near_methyl, 'chain neighbour methyl',
            specs: [methyl_on_bridge])
          w.raw_position(
            :target,
            [methyl_on_bridge, methyl_on_bridge.atom(:cb)],
            position_100_front
          ); w
        end
        set(:there_methyl) do
          near_methyl.concretize(
            target: [activated_bridge, activated_bridge.atom(:ct)])
        end
      end

    end
  end
end
