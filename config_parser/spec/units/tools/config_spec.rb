module VersatileDiamond
  module Tools

    describe Config do
      let(:error) { Config::AlreadyDefined }
      before(:each) { Config.reset }

      describe "#total_time" do
        it "duplicating" do
          Config.total_time(1, 'sec')
          -> { Config.total_time(12, 'sec') }.should raise_error error
        end
      end

      describe "#gas_concentration" do
        let(:methyle) do
          c = Concepts::Atom.new('C', 4)
          spec = Concepts::Spec.new(:methane, c: c)
          specific_atom = Concepts::SpecificAtom.new(c)
          specific_atom.active!
          Concepts::SpecificSpec.new(spec, c: specific_atom)
        end

        it "duplicating" do
          Config.gas_concentration(methyle, 1e-3, 'mol/l')
          -> { Config.gas_concentration(methyle, 1e-5, 'mol/l') }.
            should raise_error error
        end
      end

      describe "#surface_composition" do
        let(:atom) do
          a = Concepts::Atom.new('C', 4)
          a.lattice = Concepts::Lattice.new(:d, 'Diamond')
          a
        end

        it "duplicating" do
          Config.surface_composition(atom)
          -> { Config.surface_composition(atom) }.should raise_error error
        end
      end

      %w(gas surface).each do |type|
        name = "#{type}_temperature"
        describe "##{name}" do
          it "duplicating" do
            Config.send(name, 100, 'C')
            -> { Config.send(name, 373, 'K') }.should raise_error error
          end
        end
      end
    end

  end
end
