#include "dump_format.h"

namespace vd
{

void DumpFormat::render(std::ostream &os, double currentTime) const
{
    uint x = _saver.x(), y = _saver.y();
    os.write((char*)&x, sizeof(x));
    os.write((char*)&y, sizeof(y));
    os.write((char*)&currentTime, sizeof(currentTime));

    uint amorphNum = 0, crystalNum = 0;
    acc().orderedEachAtomInfo([&amorphNum, &crystalNum](uint, const AtomInfo *ai){
        if (ai->atom()->lattice())
        {
            ++crystalNum;
        }
        else
        {
            ++amorphNum;
        }
    });

    //amorph
    os.write((char*)&amorphNum, sizeof(amorphNum));
    acc().orderedEachAtomInfo([this, &os](uint i, const AtomInfo *ai){
        const SavingAtom *atom = ai->atom();
        if (!atom->lattice())
        {
            const char name = *atom->name();
            ushort type = atom->type(),
                   noBonds = atom->actives() + atom->bonds();

            os.write((char*)&i, sizeof(i));
            os.write((char*)&type, sizeof(type));
            os.write((char*)&name, sizeof(name));
            os.write((char*)&noBonds, sizeof(noBonds));
        }
    });

    //crystal
    os.write((char*)&crystalNum, sizeof(crystalNum));
    acc().orderedEachAtomInfo([this, &amorphNum, &os](uint i, const AtomInfo *ai){
        if (ai->atom()->lattice())
        {
            uint index = amorphNum + i;
            ushort type = ai->atom()->type(),
                    noBonds = ai->atom()->actives() + ai->atom()->bonds();
            const char name = *ai->atom()->name();
            int3 crd = ai->atom()->lattice()->coords();

            os.write((char*)&index, sizeof(index));
            os.write((char*)&type ,sizeof(type));
            os.write((char*)&name ,sizeof(name));
            os.write((char*)&noBonds ,sizeof(noBonds));
            os.write((char*)&crd ,sizeof(crd));
        }
    });

    uint bondsNum = acc().bondsNum();
    os.write((char*)&bondsNum, sizeof(bondsNum));

    acc().orderedEachBondInfo([this, &os](uint, const BondInfo *bi){
        uint atom = bi->from();
        os.write((char*)&atom, sizeof(atom));
        atom = bi->to();
        os.write((char*)&atom, sizeof(atom));
    });
}

}
