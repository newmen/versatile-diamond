#ifndef ONE_FILE_H
#define ONE_FILE_H

#include <fstream>
#include <sstream>
#include <string>
#include "../../atoms/atom.h"
#include "detector.h"

namespace vd
{

template <class B>
class OneFile : public B
{
public:
    void writeFrom(Atom *atom, double currentTime, const Detector *detector) override;

protected:
    template <class... Args> OneFile(Args... args) : B(args...) {}

    virtual const char *separator() const = 0;
    std::string filename() const override;
};

///////////////////////////////////////////////////////////////

template <class B>
std::string OneFile<B>::filename() const
{
    std::stringstream ss;
    ss << this->name() << this->ext();
    return ss.str();
}

template <class B>
void OneFile<B>::writeFrom(Atom *atom, double currentTime, const Detector *detector)
{
    std::ofstream out(filename());

    static uint counter = 0;
    if (counter > 0)
    {
        out << separator();
    }
    ++counter;

    this->writeToFrom(out, atom, currentTime, detector);
}

}

#endif // ONE_FILE_H
