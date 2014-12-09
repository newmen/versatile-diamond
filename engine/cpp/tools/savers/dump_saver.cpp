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

    uint amorphNum = amorphAcc.atomsNum();
    _outFile.write((char*)&amorphNum, sizeof(amorphNum));

    amorphAcc.orderedEachAtomInfo([this](uint i, const AtomInfo *ai){
        _outFile.write((char*)&i, sizeof(i));

        const Atom *atom = ai->atom();
        const char name = *atom->name();
        ushort type = atom->type(), noBonds = atom->actives()+atom->bonds();

        _outFile.write((char*)&type, sizeof(type));
        _outFile.write((char*)&name, sizeof(name));
        _outFile.write((char*)&noBonds, sizeof(noBonds));
    });

    crystal->eachAtom([&crystalAcc](const Atom *atom) {
        atom->eachNeighbour([&crystalAcc, atom](Atom *nbr) {
            if (nbr->lattice())
                crystalAcc.addBondedPair(atom, nbr);
        });
    });

    uint crystalNum = crystalAcc.atomsNum();
    _outFile.write((char*)&crystalNum, sizeof(crystalNum));

    crystalAcc.orderedEachAtomInfo([this, &amorphNum](uint i, const AtomInfo *ai){
        int arraySize = 5;
        char** data = new char*[arraySize];
        std::streamsize *sizes = new std::streamsize[arraySize];

        uint index = amorphNum + i;
        ushort type = ai->atom()->type(), noBonds = ai->atom()->actives()+ai->atom()->bonds();
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
        sizes[4] = sizeof(int3);

        for (int i = 0; i < arraySize; i++)
        {
            _outFile.write(data[i], sizes[i]);
        }
    });
}

}
