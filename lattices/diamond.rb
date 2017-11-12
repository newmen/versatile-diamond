# Provides relation rules between atom for diamond crystal lattice (Fd3m space
# group). See example of lattice at http://en.wikipedia.org/wiki/Diamond_cubic
# Current diamond crystal lattice is directed upwards by face 100
class Diamond < VersatileDiamond::Lattices::Base

  # Each lattice class should have relations source file and crystal properties source
  # file in common templates directory which located at
  # /analyzer/lib/generators/code/templates/phases

  CRYSTAL_BOND_LENGTHS = {
    110 => 1.54448e-10,
    100 => 1.62e-10,
  }.freeze

  DX = DY = 2 * CRYSTAL_BOND_LENGTHS[110] * Math.sin(SP3_ANGLE / 2)
  DZ = CRYSTAL_BOND_LENGTHS[110] * Math.cos(SP3_ANGLE / 2)

  SUPPORTED_RELATIONS = [:front_110, :cross_110, :front_100, :cross_100]

  # Gets valence of zero level atom
  # @return [Integer] get the number of valence electrons
  def zero_level_crystal_atom_valence
    2
  end

  # Describes relations which belongs to major diamond crystal carbon atom
  # @return [Hash] the information about crystal carbon
  def major_crystal_atom
    crystal_atom.merge({
      relations: [bond_front_110, bond_front_110, bond_cross_110, bond_cross_110]
    })
  end

  # Describes relations of bottom surface diamond crystal atom
  # @return [Hash] quantities of required bottom relations
  def bottom_relations
    { bond_cross_110 => 2 }
  end

  # Rules for excess atoms detection and replace it than
  # @return [Hash]
  def excess_rules
    {
      front_100 => [front_110, front_110],
      cross_100 => [cross_110, cross_110],
    }
  end

  # Gets the default height of surface in atom layers
  # For diamond should be at least three layers for bond between each one the all atoms
  # @return [Integer] the number of atomic layers
  def default_surface_height
    3
  end

  # @return [Hash]
  def possible_steps
    Hash[SUPPORTED_RELATIONS.map { |rn| [send(rn), method(:"#{rn}_steps")] }]
  end

private

  # @params [Integer] x, y, z
  # @return [Array]
  def front_110_steps(x, y, z)
    [z.even? ? [x - 1, y, z + 1] : [x, y - 1, z + 1], [x, y, z + 1]]
  end

  # @params [Integer] x, y, z
  # @return [Array]
  def cross_110_steps(x, y, z)
    [[x, y, z - 1], z.even? ? [x, y + 1, z - 1] : [x + 1, y, z - 1]]
  end

  # @params [Integer] x, y, z
  # @return [Array]
  def front_100_steps(x, y, z)
    z.even? ? [[x - 1, y, z], [x + 1, y, z]] : [[x, y - 1, z], [x, y + 1, z]]
  end

  # @params [Integer] x, y, z
  # @return [Array]
  def cross_100_steps(x, y, z)
    z.even? ? [[x, y - 1, z], [x, y + 1, z]] : [[x - 1, y, z], [x + 1, y, z]]
  end

  # Detects opposite relation on same lattice
  # @param [Concepts::Bond] the relation between atoms in lattice
  # @raise [UndefinedRelation] if relation is invalid for current lattice
  # @return [Concepts::Bond] the reverse relation
  def same_lattice_opposite_relation(relation)
    if relation.face == 110
      relation.cross
    elsif relation.face == 100
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

  # Provides information on the maximum possible number of relations of diamond crystal
  # lattice for each individual atom
  #
  # @return [Hash] the hash where keys are relation options and values are maximum
  #   numbers of correspond relations
  def crystal_relations_limit
    {
      front_110 => 2,
      cross_110 => 2,
      front_100 => 2,
      cross_100 => 2,
    }
  end

  # Gets faces of crystal along that direction does not change
  # @return [Array] the array of faces that are flatten
  def flatten_faces
    [100]
  end

  # Setups common crystal atom of diamond lattice. Atom should presents in config file
  # (or need to use internal periodic table).
  #
  # @return [Hash] the hash of properties of crystal atom
  def crystal_atom
    {
      atom_name: :C,
      valence: 4
    }
  end
end
