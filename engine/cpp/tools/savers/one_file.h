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
    std::ofstream *_out = nullptr;

public:
    ~OneFile() { delete _out; }

    void writeFrom(Atom *atom, double currentTime, const Detector *detector) override;

protected:
    template <class... Args> OneFile(Args... args) : B(args...) {}

    virtual const char *separator() const = 0;
    std::string filename() const override;

private:
    std::ofstream &out();
};

///////////////////////////////////////////////////////////////

template <class B>
void OneFile<B>::writeFrom(Atom *atom, double currentTime, const Detector *detector)
{
    static uint counter = 0;
    if (counter > 0)
    {
        out() << separator();
    }
    ++counter;

    this->writeToFrom(out(), atom, currentTime, detector);
}

template <class B>
std::string OneFile<B>::filename() const
{
    std::stringstream ss;
    ss << this->name() << this->ext();
    return ss.str();
}

template <class B>
std::ofstream &OneFile<B>::out()
{
    if (_out == nullptr)
    {
        _out = new std::ofstream(filename());
    }
    return *_out;
}

}

#endif // ONE_FILE_H
