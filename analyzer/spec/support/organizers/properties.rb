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

        # Organize dependenceis between passed species
        # @param [Array] specific_species the array of organizing species
        def organize(species)
          specific_species = species.select(&:specific?)
          wrapped_bases = species - specific_species

          base_cache = make_cache(wrapped_bases)
          specific_species.each do |wrapped_specific|
            base_cache[wrapped_specific.base_name] ||=
              DependentBaseSpec.new(wrapped_specific.spec.spec)
          end

          organize_spec_dependencies!(base_cache, specific_species)
        end

        # Converts character to property
        # @param [String] char which will be converted
        # @return [Array] the pair of key and property
        def convert_char_prop(char)
          if char == '*'
            [:danglings, Concepts::ActiveBond.property]
          elsif char == 'i'
            [:relevants, Concepts::Incoherent.property]
          end
        end

        # Collects the hash of atom properties by parsing passed string
        # @param [String] str which will be parsed
        # @return [Hash] the hash of atom properties
        def convert_str_prop(str)
          chars = str.scan(/./).group_by { |c| c }.map { |c, cs| [c, cs.size] }
          chars.each_with_object({}) do |(c, num), acc|
            key, value = convert_char_prop(c)
            acc[key] ||= []
            acc[key] += [value] * num
          end
        end

        # Gets atoms property by original specie and atom and additional options which
        # describes by string
        #
        # @param [Organizers::DependentWrappedSpec] spec which is context for getting
        #   original atom properties
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom for which the original properties will be gotten
        # @param [String] str_opts the string of additional properties which will
        #   appendet to original properties
        # @return [AtomProperties] the result of merging two properties
        def raw_props(spec, keyname, str_opts)
          opts = convert_str_prop(str_opts)
          prop = Organizers::AtomProperties.new(spec, spec.spec.atom(keyname)) +
            Organizers::AtomProperties.raw(spec.spec.atom(keyname), **opts)
        end

        prop(:bridge_ct, :bridge, :ct)
        prop(:ab_ct, :activated_bridge, :ct)
        prop(:eab_ct, :extra_activated_bridge, :ct)
        prop(:aib_ct, :activated_incoherent_bridge, :ct)
        prop(:hb_ct, :hydrogenated_bridge, :ct)
        prop(:ehb_ct, :extra_hydrogenated_bridge, :ct)
        prop(:hib_ct, :hydrogenated_incoherent_bridge, :ct)
        prop(:ahb_ct, :activated_hydrogenated_bridge, :ct)
        prop(:ab_cb, :methyl_on_activated_bridge, :cb)

        prop(:bridge_cr, :bridge, :cr)
        prop(:ab_cr, :right_activated_bridge, :cr)
        prop(:hb_cr, :right_hydrogenated_bridge, :cr)
        prop(:ib_cr, :right_incoherent_bridge, :cr)
        prop(:clb_cr, :right_chlorigenated_bridge, :cr)
        prop(:tb_cc, :three_bridges_base, :cc)

        prop(:dimer_cr, :dimer, :cr)
        prop(:dimer_cl, :dimer, :cl)
        prop(:ad_cr, :activated_dimer, :cr)
        prop(:id_cr, :twise_incoherent_dimer, :cr)
        prop(:mod_cr, :methyl_on_dimer, :cr)
        prop(:mob_cr, :methyl_on_right_bridge_base, :cr)
        prop(:mob_cb, :methyl_on_bridge_base, :cb)

        prop(:pseudo_dimer_cr, :pseudo_dimer_base, :cr)

        prop(:high_cm, :high_bridge, :cm)
        prop(:cm, :methyl_on_bridge_base, :cm)
        prop(:ucm, :unfixed_methyl_on_bridge, :cm)
        prop(:imob, :incoherent_methyl_on_bridge, :cm)
        prop(:iamob, :incoherent_activated_methyl_on_bridge, :cm)
        prop(:ihmob, :incoherent_hydrogenated_methyl_on_bridge, :cm)
        prop(:bob, :cross_bridge_on_bridges_base, :cm)
        prop(:bod, :cross_bridge_on_bridges_base, :ctl)
        prop(:eob, :ethane_on_bridge_base, :c1)
        prop(:vob, :vinyl_on_bridge_base, :c1)
      end
    end
  end
end
