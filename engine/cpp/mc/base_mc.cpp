#include "base_mc.h"

namespace vd
{

void BaseMC::initCounter(BaseMCData *data) const
{
    data->makeCounter(totalEventsNum());
}

double BaseMC::doRandom(BaseMCData *data)
{
    double r = data->rand(totalRate());
    Reaction *event = mostProbablyEvent(r);
    if (event)
    {
#if defined(PRINT) || defined(MC_PRINT)
        debugPrint([&](IndentStream &os) {
            os << event->name();
        });
#endif // PRINT || MC_PRINT

        data->counter()->inc(event);
        event->doIt();
        return increaseTime(data);
    }
    else
    {
#if defined(PRINT) || defined(MC_PRINT)
        debugPrint([&](IndentStream &os) {
            os << "Event not found! Recount and sort!";
        });
#endif // PRINT || MC_PRINT

        recountTotalRate();

        if (totalRate() == 0)
        {
            return -1;
        }
        else
        {
            sort();
            return doRandom(data);
        }
    }
}

double BaseMC::increaseTime(BaseMCData *data)
{
    static double min = std::numeric_limits<double>::denorm_min();
    double r = data->rand(1.0) + min;
    double dt = -log(r) / totalRate();
    _totalTime += dt;

    return dt;
}

#if defined(PRINT) || defined(MC_PRINT)
void BaseMC::printReaction(Reaction *reaction, std::string action, std::string type, uint n)
{
    debugPrint([&](IndentStream &os) {
        os << "BaseMC::printReaction() ";
        os << action << " ";
        if (n > 1)
        {
            os << n << " ";
        }
        os << type << " (" << reaction->type() << ") ";
        reaction->info(os);
    });
}
#endif // PRINT || MC_PRINT

}
