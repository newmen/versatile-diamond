#ifdef JSONLOG
#include "json_steps_logger.h"
#include <json.hpp>
#include <fstream>

namespace vd
{

void JSONStepsLogger::appendSpec(const std::string &name, uint n)
{
    auto it = _specsStep.find(name);
    if (it == _specsStep.end())
    {
        _specsStep[name] = n;
    }
    else if (it->second + n == 0)
    {
        _specsStep.erase(it);
    }
    else
    {
        it->second += n;
    }
}

void JSONStepsLogger::step(double time, const Dict &reactions)
{
    _times.push_back(time);
    _reactions.push_back(reactions);
    _species.push_back(_specsStep);
}

void JSONStepsLogger::save() const
{
    nlohmann::json data = {
        { "times", nlohmann::json(_times) },
        { "reactions", nlohmann::json(_reactions) },
        { "species", nlohmann::json(_species) },
    };

    std::ofstream os("data.json");
    os << std::setw(2) << data;
    os.close();
}

}

#endif // JSONLOG
