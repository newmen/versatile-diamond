#include "dump_saver.h"
#include "atoms/atom.h"
#include "mol_accumulator.h"
#include "detector.h"
#include "surface_detector.h"
#include "../hand-generations/src/handbook.h"

namespace vd {

DumpSaver::DumpSaver()
{
}

DumpSaver::~DumpSaver()
{
    _outFile->close();
    delete _outFile;
}

void DumpSaver::save(double currentTime, const Amorph *amorph, const Crystal *crystal)
{
    _outFile = new std::ofstream("dump.dump");

    _outFile->write((char*)&currentTime, sizeof(currentTime));

    Detector *detector = new SurfaceDetector<Handbook>;

    MolAccumulator amorphAcc(detector), crystalAcc(detector);

    amorph->eachAtom([&amorphAcc](const Atom *atom) {
        atom->eachNeighbour([&amorphAcc, atom](Atom *nbr) {
            amorphAcc.addBondedPair(atom, nbr);
        });
    });

    crystal->eachAtom([&crystalAcc](const Atom *atom) {
        atom->eachNeighbour([&crystalAcc, atom](Atom *nbr) {
            crystalAcc.addBondedPair(atom, nbr);
        });
    });
}

}
