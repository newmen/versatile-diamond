#include "sample.h"

// Функция необходима для инициализации и регистрации объекта нейронной сети.
// Вызывается один раз в момент запуска приложения. Далее информация о каждом событии автоматически
// доставляется в нейронную сеть.
std::vector<Localizator *> createLocalizators()
{
    std::vector<Localizator *> networks;
    // тут используется только одна "сеть", а на деле их может быть сколько угодно
    networks.push_back(new Sample);
    return networks;
}
