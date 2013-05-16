class ConcreteWhere
  include Linker

  attr_reader :description

  def initialize(raw_positions, target_refs, description)
    raw_positions.each do |target_alias, link|
      atom, position = link
      link(:@links, target_refs[target_alias], atom, position)
    end
    @description = description
  end
end
