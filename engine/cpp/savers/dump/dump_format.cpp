#include "dump_format.h"

namespace vd
{

void DumpFormat::render(std::ostream &os, double currentTime) const
{
    uint x = saver().x(), y = saver().y();
    os.write((char*)&x, sizeof(x));
    os.write((char*)&y, sizeof(y));
    os.write((char*)&currentTime, sizeof(currentTime));

    uint amorphNum = 0, crystalNum = 0;
    acc().orderedEachAtomInfo([&amorphNum, &crystalNum](uint, const AtomInfo *ai){
        if (!ai->atom()->lattice())
        {
            ++amorphNum;
        }
        else
        {
            ++crystalNum;
        }
    });

    //amorph
    os.write((char*)&amorphNum, sizeof(amorphNum));
    acc().orderedEachAtomInfo([this, &os](uint i, const AtomInfo *ai){
        os.write((char*)&i, sizeof(i));

        const SavingAtom *atom = ai->atom();
        if (!atom->lattice())
        {
            const char name = *atom->name();
            ushort type = atom->type(),
                   noBonds = atom->actives() + atom->bonds();

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
            int parametersNum = 5;
            char** data = new char*[parametersNum];
            std::streamsize *sizes = new std::streamsize[parametersNum];

            uint index = amorphNum + i;
            ushort type = ai->atom()->type(),
                    noBonds = ai->atom()->actives() + ai->atom()->bonds();
            const char name = *ai->atom()->name();
            int3 crd = ai->atom()->lattice()->coords();

            data[0] = (char*)&index;
            sizes[0] = sizeof(index);
            data[1] = (char*)&type;
            sizes[1] = sizeof(type);
            data[2] = (char*)&name;
            sizes[2] = sizeof(name);
            data[3] = (char*)&noBonds;
            sizes[3] = sizeof(noBonds);
            data[4] = (char*)&crd;
            sizes[4] = sizeof(crd);

            for (int i = 0; i < parametersNum; i++)
            {
                os.write(data[i], sizes[i]);
            }
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
