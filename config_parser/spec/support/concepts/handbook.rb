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
        set(:o) { Atom.new('O', 2) }
        set(:n) { Atom.new('N', 3) }
        set(:c) { Atom.new('C', 4) }
        set(:cd) do
          d = c.dup
          d.lattice = diamond; d
        end

        3.times do |i|
          set(:"c#{i}") { c.dup }
          set(:"cd#{i}") { cd.dup }
        end

        # Specific atoms:
        %w(h n c cd).each do |name|
          set(:"activated_#{name}") do
            a = SpecificAtom.new(send(name))
            a.active!; a
          end
        end
        set(:extra_activated_cd) do
          a = activated_cd.dup
          a.active!; a
        end

        # Bonds and positions:
        set(:free_bond) { Bond[face: nil, dir: nil] }
        set(:bond_110) { Bond[face: 110, dir: :front] }
        set(:bond_100) { Bond[face: 100, dir: :front] }
        set(:position_front) { Position[face: 100, dir: :front] }
        set(:position_cross) { Position[face: 100, dir: :cross] }

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

        set(:bridge_base) do
          s = SurfaceSpec.new(:bridge, ct: cd)
          cl, cr = AtomReference.new(s, :ct), AtomReference.new(s, :ct)
          s.describe_atom(:cl, cl)
          s.describe_atom(:cr, cr)
          s.link(cd, cl, bond_110)
          s.link(cd, cr, bond_110)
          s.link(cl, cr, position_front); s
        end
        set(:bridge) { SpecificSpec.new(bridge_base) }
        set(:activated_bridge) do
          SpecificSpec.new(bridge_base, ct: activated_cd)
        end
        set(:extra_activated_bridge) do
          SpecificSpec.new(bridge_base, ct: extra_activated_cd)
        end
        set(:extended_bridge_base) { bridge_base.extend_by_references }

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
        set(:methyl_on_extended_bridge_base) do
          methyl_on_bridge_base.extend_by_references
        end

        set(:high_bridge_base) do
          s = SurfaceSpec.new(:high_bridge)
          s.adsorb(methyl_on_bridge_base)
          s.link(s.atom(:cm), s.atom(:cb), free_bond); s
        end

        set(:dimer_base) do
          s = SurfaceSpec.new(:dimer_base)
          s.adsorb(bridge_base)
          s.rename_atom(:ct, :cr)
          s.adsorb(bridge_base)
          s.rename_atom(:ct, :cl)
          s.link(s.atom(:cr), s.atom(:cl), bond_100); s
        end
        set(:dimer) { SpecificSpec.new(dimer_base) }
        set(:activated_dimer) do
          SpecificSpec.new(dimer_base, cr: activated_cd)
        end
        set(:extended_dimer_base) { dimer_base.extend_by_references }

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

        # Reactions:
        set(:md_source) { [methyl_on_bridge] }
        set(:md_products) { [methyl, activated_bridge] }
        set(:md_names_to_specs) do {
          source: [[:mob, methyl_on_bridge]],
          products: [[:m, methyl], [:b, activated_bridge]]
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

        set(:df_source) { [activated_bridge, activated_bridge.dup] }
        set(:df_products) { [dimer] }
        set(:df_names_to_specs) do {
          source: [[:b1, activated_bridge], [:b2, df_source.last]],
          products: [[:d, dimer]]
        } end
        set(:df_atom_map) do
          Mcs::AtomMapper.map(df_source, df_products, df_names_to_specs)
        end
        set(:dimer_formation) do
          Reaction.new(:forward, 'dimer formation',
            df_source, df_products, df_atom_map)
        end

        # Environments:
        set(:dimers_row) do
          Environment.new(:dimers_row, targets: [:one, :two])
        end
        set(:at_end) do
          Where.new(:at_end, 'at end of dimers row', specs: [dimer])
        end
        set(:on_end) do
          at_end.concretize(one: dimer.atom(:cl), two: dimer.atom(:cr))
        end

        set(:near_methyl) do
          Where.new(:near_methyl, 'chain neighbour methyl',
            specs: [methyl_on_bridge])
        end
        set(:there_methyl) do
          near_methyl.concretize(target: methyl_on_bridge.atom(:cb))
        end
      end

    end
  end
end
