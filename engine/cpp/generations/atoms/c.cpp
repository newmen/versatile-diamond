#include "c.h"

void C::specifyType()
{
    switch (type())
    {
    case 0:
        setType(20);
        break;
    case 1:
        setType(11);
        break;
    case 3:
        setType(12);
        break;
    case 4:
        setType(18);
        break;
    case 6:
        setType(10);
        break;
    case 16:
        setType(15);
        break;
    case 14:
    case 17:
        setType(13);
        break;
    }
}

void C::findSpecs()
{

}
