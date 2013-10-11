#include <generations/crystals/diamond.h>

using namespace vd;

class OpenDiamond : public Diamond
{
public:
    using Diamond::Diamond;

    Atom *atom(const int3 &coords) { return atoms()[coords]; }
};

int main(int argc, char const *argv[])
{
    OpenDiamond *diamond = new OpenDiamond(dim3(10, 10, 5));
    diamond->initialize();
    assert(diamond->countAtoms() == 200);
    delete diamond;

    diamond = new OpenDiamond(dim3(5, 5, 5), 3);
    diamond->initialize();
    assert(diamond->countAtoms() == 75);

    C *c = new C(3, 0, (Lattice *)0);
    diamond->insert(c, int3(3, 3, 3));
    assert(diamond->atom(int3(3, 3, 3)) == c);
    assert(c->lattice());
    assert(c->lattice()->coords().x == 3);
    assert(c->lattice()->coords().y == 3);
    assert(c->lattice()->coords().z == 3);

    diamond->erase(c);
    assert(!diamond->atom(int3(3, 3, 3)));
    assert(!c->lattice());

    diamond->insert(c, int3(1, 2, 3));
    assert(diamond->atom(int3(1, 2, 3)) == c);
    assert(c->lattice());

    diamond->remove(c);
    assert(!diamond->atom(int3(1, 2, 3)));
    assert(!c->lattice());

    delete diamond;

    return 0;
}
