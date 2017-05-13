module VersatileDiamond
  module Organizers
    module Support

      # Provides classified atom properties instances for RSpec
      module ClassifiedPropertiesExamples
        shared_context :with_ubiquitous do
          let(:ubiquitous_reactions) do
            [dept_surface_activation, dept_surface_deactivation]
          end
        end

        shared_context :classified_props do
          def raw_props_idx(spec, keyname, str_opts)
            classifier.index(raw_prop(spec, keyname, str_opts))
          end

          # Converts character to property
          # @param [String] char which will be converted
          # @return [Array] the pair of key and property
          def convert_char_prop(char)
            if char == '*'
              [:danglings, Concepts::ActiveBond.property]
            elsif char == 'H'
              [:danglings, Concepts::AtomicSpec.new(Concepts::Atom.hydrogen)]
            elsif char == 'i'
              [:relevants, Concepts::Incoherent.property]
            elsif char == 'u'
              [:relevants, Concepts::Unfixed.property]
            end
          end

          # Collects the hash of atom properties by parsing passed string
          # @param [String] str which will be parsed
          # @return [Hash] the hash of atom properties
          def convert_str_prop(str)
            chars = str.scan(/./).group_by(&:itself).map { |c, cs| [c, cs.size] }
            chars.each_with_object({}) do |(c, num), acc|
              key, value = convert_char_prop(c)
              acc[key] ||= []
              acc[key] += [value] * num
            end
          end

          # @param [DependentWrappedSpec] spec
          # @param [Symbol] keyname
          # @param [String] str_opts
          # @return [AtomProperties]
          def raw_prop(spec, keyname, str_opts)
            atom = spec.spec.atom(keyname)
            result = AtomProperties.new(spec, atom) +
              AtomProperties.raw(atom, **convert_str_prop(str_opts))
            result ||
              raise("Incorrect aproperties for #{spec.name}(#{keyname}: #{str_opts})")
          end

          let(:ct_ss) { raw_props_idx(dept_bridge_base, :ct, '**') }
          let(:ct_is) { raw_props_idx(dept_bridge_base, :ct, 'i*') }
          let(:ct_s) { raw_props_idx(dept_bridge_base, :ct, '*') }
          let(:ct_f) { raw_props_idx(dept_bridge_base, :ct, '') }
          let(:ct_ih) { raw_props_idx(dept_bridge_base, :ct, 'iH') }
          let(:ct_hh) { raw_props_idx(dept_bridge_base, :ct, 'HH') }
          let(:ct_sh) { raw_props_idx(dept_bridge_base, :ct, '*H') }
          let(:br_h) { raw_props_idx(dept_bridge_base, :cr, 'H') }
          let(:br_s) { raw_props_idx(dept_bridge_base, :cr, '*') }
          let(:br_i) { raw_props_idx(dept_bridge_base, :cr, 'i') }
          let(:br_f) { raw_props_idx(dept_bridge_base, :cr, '') }
          let(:br_m) { raw_props_idx(dept_methyl_on_right_bridge_base, :cr, '') }
          let(:cb_h) { raw_props_idx(dept_methyl_on_bridge_base, :cb, 'H') }
          let(:cb_s) { raw_props_idx(dept_methyl_on_bridge_base, :cb, '*') }
          let(:cb_i) { raw_props_idx(dept_methyl_on_bridge_base, :cb, 'i') }
          let(:cb_f) { raw_props_idx(dept_methyl_on_bridge_base, :cb, '') }
          let(:cd_h) { raw_props_idx(dept_dimer_base, :cr, 'H') }
          let(:cd_s) { raw_props_idx(dept_dimer_base, :cr, '*') }
          let(:cd_i) { raw_props_idx(dept_dimer_base, :cr, 'i') }
          let(:cd_f) { raw_props_idx(dept_dimer_base, :cr, '') }
          let(:md_d) { raw_props_idx(dept_methyl_on_dimer_base, :cr, '') }
          let(:bd_c) { raw_props_idx(dept_bridge_with_dimer_base, :cr, '') }
          let(:tb_c) { raw_props_idx(dept_three_bridges_base, :cc, '') }
          let(:cm_sss) { raw_props_idx(dept_methyl_on_bridge_base, :cm, '***') }
          let(:cm_ssh) { raw_props_idx(dept_methyl_on_bridge_base, :cm, '**H') }
          let(:cm_shh) { raw_props_idx(dept_methyl_on_bridge_base, :cm, '*HH') }
          let(:cm_hhh) { raw_props_idx(dept_methyl_on_bridge_base, :cm, 'HHH') }
          let(:cm_s) { raw_props_idx(dept_methyl_on_bridge_base, :cm, '*') }
          let(:cm_h) { raw_props_idx(dept_methyl_on_bridge_base, :cm, 'H') }
          let(:cm_i) { raw_props_idx(dept_methyl_on_bridge_base, :cm, 'i') }
          let(:cm_f) { raw_props_idx(dept_methyl_on_bridge_base, :cm, '') }
          let(:hm_ss) { raw_props_idx(dept_high_bridge_base, :cm, '**') }
          let(:hm_hh) { raw_props_idx(dept_high_bridge_base, :cm, 'HH') }
          let(:hm_sh) { raw_props_idx(dept_high_bridge_base, :cm, '*H') }
          let(:hm_ih) { raw_props_idx(dept_high_bridge_base, :cm, 'iH') }
          let(:hm_f) { raw_props_idx(dept_high_bridge_base, :cm, '') }
          let(:hc_f) { raw_props_idx(dept_high_bridge_base, :cb, '') }
          let(:cv_i) { raw_props_idx(dept_vinyl_on_bridge_base, :c1, 'i') }
          let(:cv_f) { raw_props_idx(dept_vinyl_on_bridge_base, :c1, '') }
          let(:cw_i) { raw_props_idx(dept_vinyl_on_bridge_base, :c2, 'i') }
          let(:cw_f) { raw_props_idx(dept_vinyl_on_bridge_base, :c2, '') }
          let(:sm_hh) { raw_props_idx(dept_cross_bridge_on_bridges_base, :cm, 'HH') }
          let(:sm_sh) { raw_props_idx(dept_cross_bridge_on_bridges_base, :cm, '*H') }
          let(:sm_ss) { raw_props_idx(dept_cross_bridge_on_bridges_base, :cm, '**') }
          let(:sm_f) { raw_props_idx(dept_cross_bridge_on_bridges_base, :cm, '') }
        end
      end

    end
  end
end
