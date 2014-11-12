module VersatileDiamond
  module Generators
    module Code
      module Algorithm
        module Support

          module RoleChecker
            ANCHOR_KEYNAMES = [
              :ct, :cr, :cl, :cb, :cm, :cc, :c1, :c2, :ctl, :ctr, :csl, :csr
            ].freeze

            # @param [DependentWrappedSpec] spec
            # @param [Symbol] keyname
            def role(spec, keyname)
              classifier.index(spec, spec.spec.atom(keyname))
            end
          end

        end
      end
    end
  end
end
