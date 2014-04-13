module VersatileDiamond
  module Concepts
    module Support

      # Provides concept instances for RSpec
      module Handbook
        include Tools::Handbook

        # Lattices:
        set(:diamond) { Lattice.new(:d, 'Diamond') }

        # Atoms:
        set(:h) { Atom.new('H', 1) }
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
            SpecificAtom.new(send(name), options: [:active])
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
        set(:incoherent_c) { SpecificAtom.new(c, options: [:incoherent]) }
        set(:incoherent_cd) { SpecificAtom.new(cd, options: [:incoherent]) }
        set(:incoherent_activated_cd) do
          SpecificAtom.new(cd, options: [:incoherent, :active])
        end
        set(:unfixed_c) { SpecificAtom.new(c, options: [:unfixed]) }
        set(:unfixed_activated_c) do
          SpecificAtom.new(c, options: [:unfixed, :active])
        end

        set(:c_hydride) { SpecificAtom.new(c, monovalents: [:H]) }
        set(:cd_chloride) { SpecificAtom.new(cd, monovalents: [:Cl]) }
        set(:cd_hydride) { SpecificAtom.new(cd, monovalents: [:H]) }
        set(:cd_extra_hydride) { SpecificAtom.new(cd, monovalents: [:H] * 2) }
        set(:activated_cd_hydride) do
          SpecificAtom.new(cd, options: [:active], monovalents: [:H])
        end
        set(:incoherent_cd_hydride) do
          SpecificAtom.new(cd, options: [:incoherent], monovalents: [:H])
        end

        # Few atoms for different cases
        3.times do |i|
          set(:"c#{i}") { c.dup }
          set(:"cd#{i}") { cd.dup }
          set(:"activated_cd#{i}") { activated_cd.dup }
        end

        # Bonds and positions:
        set(:free_bond) { Bond[face: nil, dir: nil] }
        [:front, :cross].each do |dir|
          [100, 110].each do |face|
            set(:"bond_#{face}_#{dir}") { Bond[face: face, dir: dir] }
            set(:"position_#{face}_#{dir}") { Position[face: face, dir: dir] }
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
        set(:hydrogen_ion) do
          SpecificSpec.new(hydrogen_base, h: activated_h)
        end

        set(:methane_base) { GasSpec.new(:methane, c: c) }
        set(:methane) { SpecificSpec.new(methane_base) }
        set(:methyl) do
          SpecificSpec.new(methane_base, c: activated_c)
        end

        set(:ethylene_base) do
          s = GasSpec.new(:ethylene, c1: c1, c2: c2)
          s.link(c1, c2, free_bond)
          s.link(c1, c2, free_bond); s
        end
        set(:vinyl) { SpecificSpec.new(ethylene_base, c1: activated_c) }

        def make_bridge_base(name)
          s = SurfaceSpec.new(name, ct: cd)
          cl, cr = AtomReference.new(s, :ct), AtomReference.new(s, :ct)
          s.describe_atom(:cl, cl)
          s.describe_atom(:cr, cr)
          s.link(cd, cl, bond_110_cross)
          s.link(cd, cr, bond_110_cross); s
        end

        set(:bridge_base) { make_bridge_base(:bridge) }
        set(:bridge_base_dup) do
          s = make_bridge_base(:bridge_dup)
          s.rename_atom(:ct, :t)
          s.rename_atom(:cr, :r)
          s.rename_atom(:cl, :l); s
        end

        set(:bridge) { SpecificSpec.new(bridge_base) }
        set(:activated_bridge) do
          SpecificSpec.new(bridge_base, ct: activated_cd)
        end
        set(:hydrogenated_bridge) do
          SpecificSpec.new(bridge_base, ct: cd_hydride)
        end
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
          a = SpecificAtom.new(bridge_base.atom(:cr), options: [:active])
          SpecificSpec.new(bridge_base, cr: a)
        end
        set(:right_incoherent_bridge) do
          a = SpecificAtom.new(bridge_base.atom(:cr), options: [:incoherent])
          SpecificSpec.new(bridge_base, cr: a)
        end
        set(:right_hydrogenated_bridge) do
          a = SpecificAtom.new(bridge_base.atom(:cr), monovalents: [:H])
          SpecificSpec.new(bridge_base, cr: a)
        end
        set(:right_chlorigenated_bridge) do
          a = SpecificAtom.new(bridge_base.atom(:cr), monovalents: [:Cl])
          SpecificSpec.new(bridge_base, cr: a)
        end
        set(:extended_bridge_base) { bridge_base.extend_by_references }
        set(:right_activated_extended_bridge) do
          right_activated_bridge.extended
        end

        set(:methyl_on_bridge_base) do
          s = SurfaceSpec.new(:methyl_on_bridge, cm: c)
          s.adsorb(bridge_base)
          s.rename_atom(:ct, :cb)
          s.link(c, s.atom(:cb), free_bond); s
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

        set(:high_bridge_base) do
          s = SurfaceSpec.new(:high_bridge)
          s.adsorb(methyl_on_bridge_base)
          s.link(s.atom(:cm), s.atom(:cb), free_bond); s
        end
        set(:high_bridge) { SpecificSpec.new(high_bridge_base) }

        set(:dimer_base) do
          s = SurfaceSpec.new(:dimer)
          s.adsorb(bridge_base)
          s.rename_atom(:ct, :cr)
          s.adsorb(bridge_base)
          s.rename_atom(:ct, :cl)
          s.link(s.atom(:cr), s.atom(:cl), bond_100_front); s
        end
        set(:dimer) { SpecificSpec.new(dimer_base) }
        set(:activated_dimer) do
          SpecificSpec.new(dimer_base, cr: activated_cd)
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

        # Active bond:
        set(:active_bond) { ActiveBond.new }

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
