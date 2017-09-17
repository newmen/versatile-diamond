// #include <iostream>
#include <mc/dynamic_mc.h>
#include <mc/tree_mc.h>
using namespace vd;

#include "../support/fake_mc_data.h"
#include "../support/fake_events.h"
#include "../support/fake_atom.h"

typedef std::vector<UbiquitousReaction *> UVector;
typedef std::vector<SpecReaction *> SVector;

template <class V>
V concat(std::initializer_list<V> vectors)
{
    V result;
    for (V v : vectors) result.insert(result.end(), v.begin(), v.end());
    return result;
}

template <class V>
void erase(V *v)
{
    for (auto x : *v) delete x;
}

UVector ubiquitousPack(BaseMC *mc, Atom *atom)
{
    return {
        new UEvent1(mc, atom),
        new UEvent2(mc, atom)
    };
}

UVector makeUbiquitous(BaseMC *mc, Atom *atom1, Atom *atom2, Atom *atom3)
{
    return concat({
        ubiquitousPack(mc, atom1),
        ubiquitousPack(mc, atom2),
        ubiquitousPack(mc, atom3)
    });
}

template <class TEvent>
SVector typicalPack(BaseMC *mc, ushort n)
{
    SVector result;
    for (ushort i = 0; i < n; ++i) result.push_back(new TEvent(mc));
    return result;
}

SVector makeTypical(BaseMC *mc, ushort n)
{
    ushort i = 0;
    return concat({
        typicalPack<TEvent3>(mc, n - tRates[i++]),
        typicalPack<TEvent5>(mc, n - tRates[i++]),
        typicalPack<TEvent7>(mc, n - tRates[i++]),
        typicalPack<TEvent11>(mc, n - tRates[i++]),
        typicalPack<TEvent13>(mc, n - tRates[i++]),
        typicalPack<TEvent17>(mc, n - tRates[i++]),
        typicalPack<TEvent19>(mc, n - tRates[i++])
    });
}

template <class V>
void doAll(V *v)
{
    for (auto x : *v) x->doIt();
}

double ubiquitousMinRate(ushort n)
{
    double result = 0.0;
    for (uint i = 0; i < uRates.size(); ++i)
    {
        result += uRates[i] * (uNums[i].first - uNums[i].second);
    }
    return result * n;
}

double ubiquitousTotalRate(ushort n)
{
    double result = 0.0;
    for (uint i = 0; i < uRates.size(); ++i)
    {
        result += uRates[i] * uNums[i].first;
    }
    return result * n;
}

double typicalTotalRate(ushort n)
{
    double result = 0.0;
    for (ushort x : tRates) result += (n - x) * x;
    return result;
}

void assertMC(BaseMC *mc, bool hasTotalTime, double totalRate)
{
    // std::cout << mc->totalTime() << std::endl;
    // std::cout << mc->totalRate() << "\t" << totalRate << std::endl;
    assert(!hasTotalTime || mc->totalTime() > 0);
    assert(mc->totalRate() == totalRate);
}

void check(BaseMC *mc)
{
    FakeAtom atom1(0, 0, (Lattice<Crystal> *)nullptr);
    FakeAtom atom2(0, 0, (Lattice<Crystal> *)nullptr);
    FakeAtom atom3(0, 0, (Lattice<Crystal> *)nullptr);

    FakeMCData mcData;
    mc->initCounter(&mcData);
    assertMC(mc, 0.0, 0.0);

    const ushort un = 3;
    const ushort tn = 41;
    SVector typicalReactions = makeTypical(mc, tn);
    UVector ubiquitousReactions = makeUbiquitous(mc, &atom1, &atom2, &atom3);

    const double ttRate = typicalTotalRate(tn);
    const double utRate = ubiquitousTotalRate(un);
    const double umRate = ubiquitousMinRate(un);

    doAll(&typicalReactions);
    assertMC(mc, false, ttRate);

    doAll(&typicalReactions);
    assertMC(mc, false, 0.0);

    doAll(&ubiquitousReactions); // 0
    assertMC(mc, false, utRate);

    doAll(&ubiquitousReactions); // 1
    assertMC(mc, false, utRate);

    doAll(&ubiquitousReactions); // 2
    assertMC(mc, false, umRate);

    doAll(&ubiquitousReactions); // 3
    assertMC(mc, false, utRate);

    doAll(&ubiquitousReactions); // 4
    assertMC(mc, false, utRate + umRate);

    doAll(&ubiquitousReactions); // 5
    assertMC(mc, false, 0.0);

    doAll(&ubiquitousReactions); // 6
    assertMC(mc, false, utRate);

    doAll(&typicalReactions);
    double totalRate = ttRate + utRate;
    assertMC(mc, false, totalRate);

    for (ushort ti = 0; ti < FAKE_TS_NUM; ++ti)
    {
        ushort currRate = tRates[ti];
        for (ushort rb = tn - currRate; rb > 0; --rb)
        {
            mcData.set(rb * currRate - 0.1);
            assert(mc->doRandom(&mcData) > 0.0);
            totalRate -= currRate;
            assertMC(mc, true, totalRate);
        }
    }

    assert(totalRate == utRate);

    doAll(&typicalReactions);
    totalRate = ttRate + utRate;
    assertMC(mc, true, totalRate);

    for (ushort ti = 0; ti < FAKE_TS_NUM; ++ti)
    {
        ushort currRate = tRates[ti];
        for (ushort rb = 0; rb < tn - currRate; ++rb)
        {
            mcData.set(0.0);
            assert(mc->doRandom(&mcData) > 0.0);
            totalRate -= currRate;
            assertMC(mc, true, totalRate);
        }
    }

    assert(totalRate == utRate);

    auto uBegin = ubiquitousReactions.begin();
    UVector restUReactions, excessUReactions;
    restUReactions.insert(restUReactions.begin(), uBegin, uBegin + 1);
    excessUReactions.insert(excessUReactions.begin(), uBegin + 2, ubiquitousReactions.end());

    doAll(&excessUReactions); // 7
    assertMC(mc, true, utRate);

    doAll(&excessUReactions); // 8
    assertMC(mc, true, (utRate + umRate * 2) / 3);

    doAll(&excessUReactions); // 9
    assertMC(mc, true, utRate);

    doAll(&excessUReactions); // 10
    assertMC(mc, true, utRate + umRate * 2 / 3);

    doAll(&excessUReactions); // 11
    assertMC(mc, true, utRate / 3);

    totalRate = utRate / 3;
    double shift = 0.0;
    for (ushort ui = 0; ui < FAKE_US_NUM; ++ui)
    {
        auto currNums = uNums[ui];
        ushort currDiff = currNums.first - currNums.second;
        ushort currRate;
        for (ushort ci = 7; ci < 10; ++ci)
        {
            currRate = ((ci < 9) ? currNums.first : currDiff) * uRates[ui];
            mcData.set(shift + currRate - 0.1);
            assert(mc->doRandom(&mcData) > 0.0); // 7, 8, 9
            totalRate += ((ci == 7) ?
                              0.0 : ((ci == 8) ?
                                         -currNums.second : currNums.second)) * uRates[ui];
            assertMC(mc, true, totalRate);
        }
        shift = currNums.first;
    }

    assert(totalRate == utRate / 3);

    shift = 0.0;
    for (ushort ui = 0; ui < FAKE_US_NUM; ++ui)
    {
        auto currNums = uNums[ui];
        ushort currDiff = currNums.first - currNums.second;
        ushort currRate;
        for (ushort ci = 10; ci < 12; ++ci)
        {
            mcData.set(shift);
            assert(mc->doRandom(&mcData) > 0.0); // 10, 11
            totalRate += ((ci == 10) ?
                              currDiff : -currDiff - currNums.first) * uRates[ui];
            assertMC(mc, true, totalRate);
        }
        shift = currNums.first;
    }

    assert(totalRate == 0.0);

    erase(&ubiquitousReactions); // do not required if ubiquitous reactions are containing in MC
    erase(&typicalReactions);

    delete mc;
}

int main(int argc, const char *argv[])
{
    check(new DynamicMC(FAKE_TS_NUM, FAKE_US_NUM));
    check(new TreeMC(FAKE_TS_NUM, FAKE_US_NUM));

    return 0;
}
