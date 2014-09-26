#ifndef INIT_H
#define INIT_H

#include <vector>
#include <localizators/localizator.h>

// Обязательная функция, которая должна возвращать вектор указателей на экземпляры нейронных сетей,
// память на которые выделяется в куче.
std::vector<Localizator *> createLocalizators();

#endif // INIT_H
