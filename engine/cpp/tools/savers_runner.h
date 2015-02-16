#ifndef SAVERSRUNNER_H
#define SAVERSRUNNER_H

#include <vector>
#include "savers/volume_saver.h"

namespace vd {

class SaversRunner
{
    struct saver
    {
        double accumTime = 0, eachSave;

        saver(double each) : eachSave(each) {}

        void setTime(double dt) { accumTime += dt; }
    };

    vector<uint> _saversIndex;

public:
    SaversRunner();


    void addSaver(VolumeSaver* sav, double time);
    void isNeedSave(double dt);

};

}

#endif // SAVERSRUNNER_H
