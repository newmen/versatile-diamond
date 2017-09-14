#include <vector>
#include <utility>

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

template <class B, class MC, ushort TYPE, ushort RATE>
class BaseEvent : public B
{
private:
    MC *_mc;

public:
    template <class... Args>
    BaseEvent(MC *mc, Args... args) : B(args...), _mc(mc) {}

    ushort type() const override { return TYPE; }
    double rate() const override { return RATE; }

protected:
    MC *mc() { return _mc; }
};

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

template <class MC, ushort TYPE, ushort RATE, ushort SN, ushort ON>
class BaseUEvent : public BaseEvent<UbiquitousReaction, MC, TYPE, RATE>
{
private:
    uint _counter = 0;

public:
    BaseUEvent(MC *mc, Atom *atom) :
        BaseEvent<UbiquitousReaction, MC, TYPE, RATE>(mc, atom) {}

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

template <class MC>
class UEvent1 : public BaseUEvent<MC, 0, 1, 37, 23>
{
public:
    UEvent1(MC *mc, Atom *atom) : BaseUEvent<MC, 0, 1, 37, 23>(mc, atom) {}
    const char *name() const override { return "U1"; }
};

//////////////////////////////////////////////////////////////////////////////////////

template <class MC>
class UEvent2 : public BaseUEvent<MC, 1, 2, 31, 29>
{
public:
    UEvent2(MC *mc, Atom *atom) : BaseUEvent<MC, 1, 2, 31, 29>(mc, atom) {}
    const char *name() const override { return "U2"; }
};

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

template <class MC, ushort TYPE, ushort RATE>
class BaseTEvent : public BaseEvent<SpecReaction, MC, TYPE, RATE>
{
private:
    bool _isStored = false;

public:
    BaseTEvent(MC *mc) : BaseEvent<SpecReaction, MC, TYPE, RATE>(mc) {}
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

template <class MC>
class TEvent3 : public BaseTEvent<MC, 0, 3>
{
public:
    TEvent3(MC *mc) : BaseTEvent<MC, 0, 3>(mc) {}
    const char *name() const override { return "T3"; }
};

//////////////////////////////////////////////////////////////////////////////////////

template <class MC>
class TEvent5 : public BaseTEvent<MC, 1, 5>
{
public:
    TEvent5(MC *mc) : BaseTEvent<MC, 1, 5>(mc) {}
    const char *name() const override { return "T5"; }
};

//////////////////////////////////////////////////////////////////////////////////////

template <class MC>
class TEvent7 : public BaseTEvent<MC, 2, 7>
{
public:
    TEvent7(MC *mc) : BaseTEvent<MC, 2, 7>(mc) {}
    const char *name() const override { return "T7"; }
};

//////////////////////////////////////////////////////////////////////////////////////

template <class MC>
class TEvent11 : public BaseTEvent<MC, 3, 11>
{
public:
    TEvent11(MC *mc) : BaseTEvent<MC, 3, 11>(mc) {}
    const char *name() const override { return "T11"; }
};

//////////////////////////////////////////////////////////////////////////////////////

template <class MC>
class TEvent13 : public BaseTEvent<MC, 4, 13>
{
public:
    TEvent13(MC *mc) : BaseTEvent<MC, 4, 13>(mc) {}
    const char *name() const override { return "T13"; }
};

//////////////////////////////////////////////////////////////////////////////////////

template <class MC>
class TEvent17 : public BaseTEvent<MC, 5, 17>
{
public:
    TEvent17(MC *mc) : BaseTEvent<MC, 5, 17>(mc) {}
    const char *name() const override { return "T17"; }
};

//////////////////////////////////////////////////////////////////////////////////////

template <class MC>
class TEvent19 : public BaseTEvent<MC, 6, 19>
{
public:
    TEvent19(MC *mc) : BaseTEvent<MC, 6, 19>(mc) {}
    const char *name() const override { return "T19"; }
};
