module VersatileDiamond
  module Generators
    module Code
      module Support

        module BaseReactionExamples
          shared_examples_for :check_main_names do
            it { expect(subject.class_name).to eq(class_name) }
            it { expect(subject.enum_name).to eq(enum_name) }
            it { expect(subject.file_name).to eq(file_name) }
            it { expect(subject.print_name).to eq(print_name) }
          end

          shared_examples_for :check_base_class_name do
            let(:base_class_name) { "#{outer_class_name}<#{templ_args.join(', ')}>" }
            it { expect(subject.base_class_name).to eq(base_class_name) }
          end

          shared_examples_for :check_gas_concentrations do
            it { expect(subject.gas_concentrations).to eq(env_concs) }
          end
        end

      end
    end
  end
end
