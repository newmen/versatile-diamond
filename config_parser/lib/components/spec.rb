# Структура содержит атомы и связи между ними.
# Когда одна структура включает другую - происходит копирование атомов и связей из включаемой структуры во включающую.
# Если структура является рекурсивной, то копирования не происходит, а создаётся ссылка на используемый атом.

class Spec < Component
  class << self
    def [](name)
      @@common_specs[name]
    end

    def add(name)
      spec = new(name)
      # @local_specs ||= {} # TODO: unused variable!
      # @local_specs[name] = spec
      @@common_specs ||= {}
      @@common_specs[name] = spec
    end
  end

  def initialize(name)
    @name = name
    @atoms, @links = {}, {}
    @aliases = {}
  end

  def [](atom_keyname)
    @atoms[atom_keyname]
  end

  def aliases(**refs)
    refs.each do |keyname, spec_name|
      spec = Spec[spec_name.to_sym]
      duplicated_atoms = spec.duplicate_atoms
      adsorb_links(spec.links, duplicated_atoms)
      @aliases[keyname] = spec.alias_atoms(duplicated_atoms)
    end
  end

  def atoms(**refs)
    refs.each do |keyname, atom|
      real_atom = detect_atom(atom)
      @atoms[keyname] = real_atom
      @links[real_atom] ||= []
    end
  end

  %w(bond position).each do |method_name|
    define_method(method_name) do |first, second, **options|
      first, second = existing_atoms(first, second)
      unless options.empty? || first.specified? || second.specified?
        syntax_error('spec.incorrect_linking_unspecified_atoms')
      end
      instance = constantize(method_name)[options]
      @links[first] = [second, instance]
      @links[second] = [first, instance]
    end
  end

  def dbond(first, second)
    2.times { bond(first, second) }
  end

protected

  attr_reader :name, :links

  def duplicate_atoms
    atoms = @atoms.values
    Hash[atoms.zip(atoms.map(&:dup))]
  end

  def alias_atoms(duplicated_atoms)
    Hash[@atoms.map { |key, atom| [key, duplicated_atoms[atom]] }]
  end

private

  def detect_atom(atom_str)
    atom = simple_atom(atom_str) || defined_atom(atom_str)
    atom || syntax_error('spec.undefined_atom', atom: atom_str)
  end

  def simple_atom(atom_str)
    Atom[atom_str] if atom_str =~ /\A[A-Z][a-z0-9]*\Z/
  end

  def defined_atom(atom_str)
    if atom_str =~ /\A(?<spec>[a-z][a-z0-9_]*)\(:(?<atom>[a-z][a-z0-9_]*)\)\Z/
      spec_sym, atom_sym = $~[:spec].to_sym, $~[:atom].to_sym
      if spec_sym == @name
        AtomReference.new(self, atom_sym)
      elsif (aliased_spec = @aliases[spec_sym])
        aliased_spec[atom_sym]
      else
        spec = Spec[spec_sym]
        duplicated_atoms = spec.duplicate_atoms
        adsorb_links(spec.links, duplicated_atoms)
        duplicated_atoms[spec[atom_sym]]
      end
    end
  end

  def adsorb_links(readsorbed_links, duplicated_atoms)
    readsorbed_links.each do |atom, links|
      curr_links = @links[duplicated_atoms[atom]] = []
      links.each do |another_atom, bond_instance|
        curr_links << [duplicated_atoms[another_atom], bond_instance]
      end
    end
  end

  def existing_atoms(*atom_syms)
    atom_syms.map do |atom_sym|
      self.[](atom_sym) || syntax_error('spec.undefined_atom', atom: atom_sym)
    end
  end
end
