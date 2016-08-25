#ifndef VOLUME_SAVER_H
#define VOLUME_SAVER_H

#include "file_saver.h"
#include "detector.h"

namespace vd
{

class VolumeSaver : public FileSaver
{
    const Detector *_detector;

protected:
    VolumeSaver(const Config *config, const Detector *detector) :
        FileSaver(config), _detector(detector) {}

    ~VolumeSaver() { delete _detector; }

    const Detector *detector() const { return _detector; }
};

}

#endif // VOLUME_SAVER_H
