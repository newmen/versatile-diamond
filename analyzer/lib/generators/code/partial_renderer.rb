module VersatileDiamond
  module Generators
    module Code

      # Provides methods for render partials of templates
      module PartialRenderer

        PARTIAL_PREFIX = '_'

      private

        # Provides ability to pass hash of local variables to rendering partial
        class LocalVars
          # Initializes the forwarding object by main object
          # @param [Object] main object to which will be passed all calls if them
          #   aren't in binding local variables
          def initialize(main)
            @main = main
          end

          # Binds passed local variables with correspond names for using in partial
          # template
          #
          # @param [Hash] locals the hash of local variables which values will be
          #   available in partial template by key
          # @return [Binding] the current class instance environment
          def bind(locals)
            @locals = Hash[locals.map { |k, v| [k.to_sym, v] }]
            binding
          end

          # Provides ability to call local variables by them names or pass the call
          # to main object
          #
          # @param [Array] args which will be passed to main object if first item of
          #   this array is not a name of local variable
          # @return [Object] the value of local variable or main object method result
          def method_missing(*args)
            var = args.first.to_sym
            @locals[var] || @main.send(*args)
          end
        end

        # Renders partial template and gets result
        # @param [String] path to partial without partial prefix
        # @return [String] the rendering result
        def render_partial(path, locals: {})
          bind = LocalVars.new(self).bind(locals)
          make_erb(File.read(partial_path(path))).result(bind)
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
