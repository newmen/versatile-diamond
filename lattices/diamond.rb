# Provides relation rules between atom for diamond crystal lattice (Fd3m space
# group). See example of lattice at http://en.wikipedia.org/wiki/Diamond_cubic
class Diamond < VersatileDiamond::Lattices::Base
private

  # Detects opposite relation on same lattice
  # @param [Concepts::Bond] the relation between atoms in lattice
  # @raise [WrongRelation] if relation is invalid for current lattice
  # @return [Concepts::Bond] the reverse relation
  def same_lattice(relation)
    if relation.face == 110
      relation.dir == :front ?
        relation.class[face: 110, dir: :cross] :
        relation.class[face: 110, dir: :front]
    elsif relation.face == 100 &&
      !(relation.class == Bond && relation.dir == :cross)

      relation.class[face: 100, dir: relation.dir]
    else
      raise WrongRelation, relation
    end
  end

  # No have rules described relations with another lattice
  # @raise [WrongRelation]
  def other_lattice(relation)
    raise WrongRelation, relation
  end

  # Provides compositions rules of relations for current crystal lattice
  # @return [Hash] the keys of hash keys are lists of relations by which to
  #   search for a new relation, and values is result relationship
  def relation_rules
    {
      [front_110, cross_110] => position_front_100,
      [cross_110, front_110] => position_cross_100,
      [cross_110, cross_100, front_110] => position_front_100,
      [front_110, front_100, cross_110] => position_cross_100,
      [cross_110, cross_110, front_110, front_110] => position_front_100,
      [front_110, front_110, cross_110, cross_110] => position_cross_100,
    }
  end

end
