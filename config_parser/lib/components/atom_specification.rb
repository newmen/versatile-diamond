module AtomSpecification
  refine Symbol do
    def %(lattice)
      Atom[self] % lattice
    end
  end
end
