#ifndef INIT_H
#define INIT_H

#include <localizators/localizator.h>

// Обязательная функция, которая должна возвращать вектор указателей на экземпляры нейронных сетей,
// память на которые выделяется в куче.
void registerLocalizators();

#endif // INIT_H
