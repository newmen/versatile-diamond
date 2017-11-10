#include <vector>
#include <utility>

#include <mc/base_mc.h>
#include <reactions/ubiquitous_reaction.h>
#include <reactions/spec_reaction.h>
using namespace vd;

//////////////////////////////////////////////////////////////////////////////////////

typedef std::vector<ushort> RatesType;
RatesType tRates = { 3, 5, 7, 11, 13, 17, 19 }; // same number are using below
RatesType uRates = { 1, 2 };

typedef std::vector<std::pair<ushort, ushort>> UbiquitousNums;
UbiquitousNums uNums = { { 37, 23 }, { 31, 29 } };

//////////////////////////////////////////////////////////////////////////////////////

enum : ushort {
    FAKE_US_NUM = 2,
    FAKE_TS_NUM = 7,
    FAKE_EVENTS_NUM = FAKE_US_NUM + FAKE_TS_NUM
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort TYPE, ushort RATE>
class BaseEvent : public B
{
private:
    BaseMC *_mc;

public:
    template <class... Args>
    BaseEvent(BaseMC *mc, Args... args) : B(args...), _mc(mc) {}

    ushort type() const override { return TYPE; }
    double rate() const override { return RATE; }

protected:
    BaseMC *mc() { return _mc; }
};

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

template <ushort TYPE, ushort RATE, ushort SN, ushort ON>
class BaseUEvent : public BaseEvent<UbiquitousReaction, TYPE, RATE>
{
private:
    uint _counter = 0;

public:
    BaseUEvent(BaseMC *mc, Atom *atom) :
        BaseEvent<UbiquitousReaction, TYPE, RATE>(mc, atom) {}

    void doIt() override { action(); }
    void remove() override {}

protected:
    ushort toType() const override { return 0; }
    void action() override
    {
        ushort lx = _counter % 3;
        if (_counter > 0)
            if (_counter % 2 == 0) // 2, 4, 6, 8, 10
            {
                if (lx != 0) this->mc()->remove(TYPE, this, ON); // 2, 4, 8, 10, 14
            }                                                    // !6, !12, !18, !24, !30
            else this->mc()->removeAll(TYPE, this); // 1, 3, 5, 7, 9
        if (lx != 2) this->mc()->add(TYPE, this, SN); // 0, 1, 3, 4, 6
                                                      // !2, !5, !8, !11, !14
        ++_counter;
    }
};

//////////////////////////////////////////////////////////////////////////////////////

class UEvent1 : public BaseUEvent<0, 1, 37, 23>
{
public:
    UEvent1(BaseMC *mc, Atom *atom) : BaseUEvent<0, 1, 37, 23>(mc, atom) {}
    const char *name() const override { return "U1"; }
};

//////////////////////////////////////////////////////////////////////////////////////

class UEvent2 : public BaseUEvent<1, 2, 31, 29>
{
public:
    UEvent2(BaseMC *mc, Atom *atom) : BaseUEvent<1, 2, 31, 29>(mc, atom) {}
    const char *name() const override { return "U2"; }
};

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

template <ushort TYPE, ushort RATE>
class BaseTEvent : public BaseEvent<SpecReaction, TYPE, RATE>
{
private:
    bool _isStored = false;

public:
    BaseTEvent(BaseMC *mc) : BaseEvent<SpecReaction, TYPE, RATE>(mc) {}
    void doIt() override
    {
        if (_isStored) this->remove();
        else this->store();
        _isStored = !_isStored;
    }

protected:
    void mcRemember() override { this->mc()->add(TYPE, this); };
    void mcForget() override { this->mc()->remove(TYPE, this); };
};

//////////////////////////////////////////////////////////////////////////////////////

class TEvent3 : public BaseTEvent<0, 3>
{
public:
    TEvent3(BaseMC *mc) : BaseTEvent<0, 3>(mc) {}
    const char *name() const override { return "T3"; }
};

//////////////////////////////////////////////////////////////////////////////////////

class TEvent5 : public BaseTEvent<1, 5>
{
public:
    TEvent5(BaseMC *mc) : BaseTEvent<1, 5>(mc) {}
    const char *name() const override { return "T5"; }
};

//////////////////////////////////////////////////////////////////////////////////////

class TEvent7 : public BaseTEvent<2, 7>
{
public:
    TEvent7(BaseMC *mc) : BaseTEvent<2, 7>(mc) {}
    const char *name() const override { return "T7"; }
};

//////////////////////////////////////////////////////////////////////////////////////

class TEvent11 : public BaseTEvent<3, 11>
{
public:
    TEvent11(BaseMC *mc) : BaseTEvent<3, 11>(mc) {}
    const char *name() const override { return "T11"; }
};

//////////////////////////////////////////////////////////////////////////////////////

class TEvent13 : public BaseTEvent<4, 13>
{
public:
    TEvent13(BaseMC *mc) : BaseTEvent<4, 13>(mc) {}
    const char *name() const override { return "T13"; }
};

//////////////////////////////////////////////////////////////////////////////////////

class TEvent17 : public BaseTEvent<5, 17>
{
public:
    TEvent17(BaseMC *mc) : BaseTEvent<5, 17>(mc) {}
    const char *name() const override { return "T17"; }
};

//////////////////////////////////////////////////////////////////////////////////////

class TEvent19 : public BaseTEvent<6, 19>
{
public:
    TEvent19(BaseMC *mc) : BaseTEvent<6, 19>(mc) {}
    const char *name() const override { return "T19"; }
};
