module VersatileDiamond
  module Interpreter
    module Support

      module ReactionPropertiesExamples
        shared_examples_for "reaction properties" do
          before(:each) do
            elements.interpret('atom H, valence: 1')
            gas.interpret('spec :hydrogen')
            gas.interpret('  atoms h: H')

            elements.interpret('atom N, valence: 3')
            gas.interpret('spec :ammonia')
            gas.interpret('  atoms n: N')

            reaction.interpret('equation ammonia(n: *) + hydrogen(h: *) = ammonia')
          end

          def checks_reverse
            reverse.source.size.should == 1
            reverse.products.size.should == 2
          end

          describe "#enthalpy" do
            it "enthalpy setup should makes reverse target" do
              target.interpret('enthalpy 33.1, kJ/mol')
              checks_reverse
            end
          end

          describe "#activation" do
            it "activation energy setup should makes reverse target" do
              target.interpret('activation 22.5, kJ/mol')
              checks_reverse
            end
          end

          describe "#reverse_activation" do
            it "reverse activation energy setup should makes reverse target" do
              target.interpret('reverse_activation 11.7, kJ/mol')
              checks_reverse
            end
          end

          describe "#forward_rate" do
            it "validate dimension when has two gas phase molecules" do
              expect { target.interpret('forward_rate 1e3, cm6/(mol2 * s)') }.
                not_to raise_error
            end

            describe "evaluate value" do
              before { Tools::Config.gas_temperature(100, 'C') }
              it "uses gas temperature" do
                expect { target.interpret('forward_rate 1e3 * T ** 2, cm6/(mol2 * s)') }.
                  not_to raise_error
              end
            end
          end

          describe "#reverse_rate" do
            it "reverse rate setup should makes reverse target" do
              target.interpret('reverse_rate 1e3, cm3/(mol * s)')
              checks_reverse
            end

            it "wrong dimension when has gas phase molecule" do
              expect { target.interpret('reverse_rate 1e3, 1/s') }.
                to raise_error *syntax_error('dimension.undefined_value')
            end
          end
        end
      end

    end
  end
end
