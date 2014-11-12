module VersatileDiamond
  module Generators
    module Code
      module Algorithm
        module Support

          module FindBuilderExamples
            shared_examples_for :check_code do
              let(:dept_spec) { code_specie.spec }
              RoleChecker::ANCHOR_KEYNAMES.each do |keyname|
                let(keyname) { dept_spec.spec.atom(keyname) }
                let(:"role_#{keyname}") { role(dept_spec, keyname) }
              end

              it { expect(builder.build).to eq(find_algorithm) }
            end
          end

        end
      end
    end
  end
end
