#pragma once

#include <stdexcept>
namespace fatint::error
{
class ConstraintException : public std::runtime_error
{
public:
    ConstraintException(const char *msg) : std::runtime_error(msg) {}
};
} // namespace fatint::error
