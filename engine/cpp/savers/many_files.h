#ifndef MANY_FILES_H
#define MANY_FILES_H

#include <string>
#include <sstream>
#include <fstream>
#include "../phases/amorph.h"
#include "../phases/crystal.h"
#include "detector.h"

namespace vd
{

template <class B>
class ManyFiles : public B
{
public:
    void save(double currentTime, const Amorph *amorph, const Crystal *crystal, const Detector *detector) override;

protected:
    template <class... Args> ManyFiles(Args... args) : B(args...) {}

    std::string filename() const override;
};

///////////////////////////////////////////////////////////////////////////////

template <class B>
void ManyFiles<B>::save(double currentTime, const Amorph *amorph, const Crystal *crystal, const Detector *detector)
{
    std::ofstream out(filename());
    this->saveTo(out, currentTime, amorph, crystal, detector);
}

template<class B>
std::string ManyFiles<B>::filename() const
{
    static uint n = 0;

    std::stringstream ss;
    ss << this->name() << "_" << (n++) << this->ext();
    return ss.str();
}

}

#endif // MANY_FILES_H
