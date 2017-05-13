#ifdef JSONLOG
#ifndef JSON_STEPS_LOGGER_H
#define JSON_STEPS_LOGGER_H

#include <string>
#include <list>
#include <map>
#include "short_types.h"

namespace vd
{

class JSONStepsLogger
{
public:
    typedef std::map<std::string, int> Dict;
private:
    typedef std::list<Dict> Seq;
    typedef std::list<double> Times;

    Times _times;
    Seq _reactions;
    Seq _species;
    Dict _specsStep;

public:
    JSONStepsLogger() = default;

    void appendSpec(const std::string &name, uint n);
    void step(double time, const Dict &reactions);
    void save() const;

private:
    JSONStepsLogger(const JSONStepsLogger &) = delete;
    JSONStepsLogger(JSONStepsLogger &&) = delete;
    JSONStepsLogger &operator = (const JSONStepsLogger &) = delete;
    JSONStepsLogger &operator = (JSONStepsLogger &&) = delete;
};

}

#endif // JSON_STEPS_LOGGER_H
#endif // JSONLOG
