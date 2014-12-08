#include <sstream>
#include "dump_saver.h"
#include "../../atoms/atom.h"
#include "mol_accumulator.h"
#include "surface_detector.h"

namespace vd {

DumpSaver::DumpSaver()
{
}

DumpSaver::~DumpSaver()
{
    _outFile.close();
}

void DumpSaver::save(double currentTime, const Amorph *amorph, const Crystal *crystal, const Detector *detector)
{
    _outFile.open("dump.dump");
    MolAccumulator amorphAcc(detector), crystalAcc(detector);

    _outFile.write((char*)&currentTime, sizeof(currentTime));

    amorph->eachAtom([&amorphAcc](const Atom *atom) {
        atom->eachNeighbour([&amorphAcc, atom](Atom *nbr) {
            amorphAcc.addBondedPair(atom, nbr);
        });
    });

    ushort amorphNum = amorphAcc.atomsNum();
    _outFile.write((char*)&amorphNum, sizeof(amorphAcc.atomsNum()));

    std::stringstream strm;
    amorphAcc.orderedEachAtomInfo([&strm](uint i, const AtomInfo *ai){
        strm.write((char*)&i, sizeof(i));
        const Atom *atom = ai->atom();

        const char *name = atom->name();
        ushort type = atom->type(), noBonds = atom->actives()+atom->bonds();

        strm.write((char*)&type, sizeof(type));
        strm.write((char*)&name, sizeof(name));
        strm.write((char*)&noBonds, sizeof(noBonds));
    });

    crystal->eachAtom([&crystalAcc](const Atom *atom) {
        atom->eachNeighbour([&crystalAcc, atom](Atom *nbr) {
            if (nbr->lattice())
                crystalAcc.addBondedPair(atom, nbr);
        });
    });

    crystalAcc.orderedEachAtomInfo([&strm, &amorphNum](uint i, const AtomInfo *ai){
        int arraySize = 7;
        char** data = new char*[arraySize];
        std::streamsize *sizes = new std::streamsize[arraySize];

        ushort type = ai->atom()->type(), index = amorphNum + i, noBonds = ai->atom()->actives()+ai->atom()->bonds();
        const char *name = ai->atom()->name();
        int3 crd = ai->atom()->lattice()->coords();

        data[0] = (char*)&index;
        sizes[0] = sizeof(index);
        data[1] = (char*)&type;
        sizes[1] = sizeof(type);
        data[2] = (char*)&name;
        sizes[2] = sizeof(name);
        data[3] = (char*)&noBonds;
        sizes[3] = sizeof(noBonds);
        data[4] = (char*)&crd.x;
        sizes[4] = sizeof(crd.x);
        data[5] = (char*)&crd.y;
        sizes[5] = sizeof(crd.y);
        data[6] = (char*)&crd.z;
        sizes[6] = sizeof(crd.y);

        for (int i = 0; i < arraySize; i++)
        {
            strm.write(data[i], sizes[i]);
        }
    });

    _outFile << strm;
}

}
