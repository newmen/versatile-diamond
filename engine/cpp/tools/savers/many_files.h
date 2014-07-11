#ifndef MANY_FILES_H
#define MANY_FILES_H

#include <string>
#include <sstream>
#include <fstream>
#include "../../atoms/atom.h"
#include "detector.h"

namespace vd
{

template <class B>
class ManyFiles : public B
{
public:
    template <class... Args> ManyFiles(Args... args) : B(args...) {}

    void writeFrom(Atom *atom, double currentTime, const Detector *detector) override;

protected:
    std::string filename() const override;
};

///////////////////////////////////////////////////////////////////////////////

template<class B>
std::string ManyFiles<B>::filename() const
{
    static uint n = 0;

    std::stringstream ss;
    ss << this->name() << "_" << (n++) << this->ext();
    return ss.str();
}

template <class B>
void ManyFiles<B>::writeFrom(Atom *atom, double currentTime, const Detector *detector)
{
    std::ofstream out(filename());
    this->writeToFrom(out, atom, currentTime, detector);
}

}

#endif // MANY_FILES_H