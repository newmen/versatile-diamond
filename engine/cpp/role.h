#ifndef ROLE_H
#define ROLE_H

#include <functional>
#include "common.h"

//namespace vd
//{

//struct Role
//{
//    ushort atomType;
//    ushort specType;

//    Role(ushort atomType, ushort specType) : atomType(atomType), specType(specType) {}

//    size_t hash() const noexcept
//    {
//        size_t at = atomType;
//        return (at << 16) ^ specType;
//    }
//};

////template <>
////inline size_t std::hash<Role>::operator ()(const Role &role) const noexcept
////{
////    return role.hash();
////}

//}

//// TODO: fucking incomplete class! WTF?! %E
//template <>
//inline size_t std::hash<vd::Role>::operator ()(const vd::Role &role) const noexcept
//{
//    return role.hash();
//}

#endif // ROLE_H
