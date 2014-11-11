module VersatileDiamond
  module Generators
    module Code
      module Algorithm
        module Support

          module FindBuilderExamples
            shared_examples_for :check_code do
              # @param [DependentWrappedSpec] spec
              # @param [Symbol] keyname
              def role(spec, keyname)
                classifier.index(spec, spec.spec.atom(keyname))
              end

              let(:dept_spec) { code_specie.spec }

              [
                :ct, :cr, :cl, :cb, :cm, :cc, :c1, :c2, :ctl, :ctr, :csl, :csr
              ].each do |keyname|
                let(keyname) { dept_spec.spec.atom(keyname) }
                let(:"role_#{keyname}") { role(dept_spec, keyname) }
              end

              [:ct, :cr].each do |keyname|
                let(:"b_#{keyname}") { role(dept_bridge_base, keyname) }
              end

              it { expect(builder.build).to eq(find_algorithm) }
            end
          end

        end
      end
    end
  end
end
