module VersatileDiamond

  class Environment < ComplexComponent
    class << self
      def add(env_name)
        @environments ||= {}
        @environments[env_name] = new
      end

      def [](env_name)
        @environments[env_name] || syntax_error('.undefined', name: env_name)
      end
    end

    def initialize
      @wheres = {}
    end

    def targets(*names)
      @targets = names
    end

    def aliases(**refs)
      @aliases ||= {}
      refs.each do |name, spec_name|
        @aliases[name] = Spec[spec_name.to_sym]
      end
    end

    def where(name, description)
      syntax_error('where.already_exists', name: name) if @wheres[name]
      where = Where.new(self, description)
      @wheres[name] = where
      nested(where)
    end

    def use_where(name)
      @wheres[name]
    end

    def is_target?(name)
      syntax_error('.targets_not_defined') unless @targets
      @targets.include?(name)
    end

    def resolv_alias(name)
      @aliases && @aliases[name]
    end
  end

end
