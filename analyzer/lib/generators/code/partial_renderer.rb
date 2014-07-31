module VersatileDiamond
  module Generators
    module Code

      # Provides methods for render partials of templates
      module PartialRenderer

        PARTIAL_PREFIX = '_'

      private

        # Renders partial template and gets result
        # @param [String] path to partial without partial prefix
        # @return [String] the rendering result
        def render_partial(path)
          make_erb(File.read(partial_path(path))).result(binding)
        end

        # Makes path to partial
        # @param [String] path see at #render_partial same argument
        # @return [Pathname] the correct pathname to partial, with partial prefix
        def partial_path(path)
          pname = Pathname.new(path)
          template_dir + "#{pname.dirname}/#{PARTIAL_PREFIX}#{pname.basename}.erb"
        end
      end

    end
  end
end
