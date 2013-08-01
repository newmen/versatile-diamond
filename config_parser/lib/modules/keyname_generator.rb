module VersatileDiamond
  module Modules

    # TODO: rspec
    module KeynameGenerator
      # Generates the new keyname by original keyname with adding a '_' symbol
      # before original keyname and append unique (for passed spec) number
      #
      # @param [Concepts::Spec] spec the spec for that keyname will be
      #   generated
      # @param [Symbol] original_keyname the original keyname from which will
      #   be generated new keyname
      # @return [Symbol] generated unique keyname
      def generate_keyname(spec, original_keyname)
        keyname = nil
        i = 0
        begin
          keyname = "_#{original_keyname}#{i}".to_sym
          i += 1
        end while (spec.atom(keyname))
        keyname.to_sym
      end
    end

  end
end
