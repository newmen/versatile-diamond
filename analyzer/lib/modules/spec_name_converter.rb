module VersatileDiamond
  using Patches::RichString

  module Modules

    # Provides logic for convertation names of species (with specific characters)
    module SpecNameConverter
    private

      # Converts passed name of spec to non specific characters sequence
      # @param [Symbol] name the converting name of specie
      # @param [Symbol] str_method the name of method which will applied to result
      #   string
      # @param [String] separator of parts of name
      # @option [Boolean] :tail_too flag that str_method should be applied to tail too
      # @return [String] the converted name
      def convert_name(name, str_method, separator, tail_too: true)
        m = name.to_s.match(/(\w+)(\(.+?\))?/)
        tail_parts = m[2] ? name_suffixes(m[2]) : []
        tail_parts.map! { |part| eval("part.#{str_method}") } if tail_too
        ([eval("m[1].#{str_method}")] + tail_parts).join(separator)
      end

      # Makes suffix of name which is used in name builder methods
      # @param [String] brackets_str the string which contain brackets and some
      #   additional params of specie in them
      # @return [Array] the list of name suffixes
      # @example generating name
      #   '(ct: *, ct: i, cr: i)' => 'CTsiCRi'
      def name_suffixes(brackets_str)
        params_str = brackets_str.scan(/\((.+?)\)/).first.first
        params = params_str.scan(/(\w+): (.)/)
        strs = params.group_by(&:first).map do |k, gs|
          states = gs.map { |item| item.last == '*' ? 's' : item.last }.join
          "#{k.upcase}#{states}"
        end
        strs.sort
      end
    end

  end
end
