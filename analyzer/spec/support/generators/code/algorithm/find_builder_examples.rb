module VersatileDiamond
  module Generators
    module Code
      module Algorithm
        module Support

          module FindBuilderExamples
            shared_examples_for :check_code do
              let(:dept_spec) { code_specie.spec }
              let_atoms_of(:'dept_spec.spec', RoleChecker::ANCHOR_KEYNAMES) do |kn|
                let(:"role_#{kn}") { role(dept_spec, kn) }
              end

              it { expect(builder.build).to eq(find_algorithm) }
            end
          end

        end
      end
    end
  end
end
