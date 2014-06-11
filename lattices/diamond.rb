# Provides relation rules between atom for diamond crystal lattice (Fd3m space
# group). See example of lattice at http://en.wikipedia.org/wiki/Diamond_cubic
# Current diamond crystal lattice is directed upwards by face 100
class Diamond < VersatileDiamond::Lattices::Base

  # Each lattice class should have relations template in common templates directory
  # which located at /analyzer/lib/generators/code/templates/phases

private

  # Detects opposite relation on same lattice
  # @param [Concepts::Bond] the relation between atoms in lattice
  # @raise [UndefinedRelation] if relation is invalid for current lattice
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
      raise UndefinedRelation, relation
    end
  end

  # No have rules described relations with another lattice
  # @raise [UndefinedRelation]
  def other_lattice(relation)
    raise UndefinedRelation, relation
  end

  # Provides compositions of inference rules for found position relations in
  # current crystal lattice
  #
  # @return [Hash] the keys of hash keys are lists of relations by which to
  #   search for a new relation, and values is result relationship
  def inference_rules
    {
      [front_110, cross_110] => position_front_100,
      [cross_110, front_110] => position_cross_100,
      # [front_110, front_110] => position_111,
      # [cross_110, cross_110] => position_111,
    }
  end

  # The periods of crystal lattice as distance values between atoms along each axis
  # where diamond lattice have top {100} plane
  # @return [Hash] the periods hash
  def periods
    { x: 2.45, y: 2.45, z: 3.57 / 4 }
  end

  # Gets the default height of surface in atom layers
  # For diamond should be at least three layers for bond between each one the all atoms
  # @return [Integer] the number of atomic layers
  def default_surface_height
    3
  end

  # Describes relations which belongs to major diamond crystal carbon atom
  # @return [Hash] the information about crystal carbon
  def major_crystal_atom
    crystal_atom.merge({
      relations: [bond_front_110, bond_front_110, bond_cross_110, bond_cross_110]
    })
  end

  # Describes relations and dangling bonds which belongs to surface diamond crystal
  # carbon atom
  #
  # @return [Hash] the information about surface carbon
  def surface_crystal_atom
    crystal_atom.merge({
      relations: [bond_cross_110, bond_cross_110],
      danglings: [:active]
    })
  end

  # Setups common crystal atom of diamond lattice. Atom should presents in config file
  # (or need to use internal periodic table).
  def crystal_atom
    {
      atom_name: :C,
      valence: 4
    }
  end

  # In order to link all atoms of initial crystal surface need to set the binding
  # face and direction
  # @return [Hash] the hash with face and direction info
  def connecting_bond
    bond_cross_110
  end
end
