#pragma once

#include <sstream>
#include <stdexcept>

namespace fatint::error
{

class ParameterConstraintException : public std::runtime_error
{
  public:
    ParameterConstraintException(const char *msg, double offending_value)
        : std::runtime_error(build_error_msg(msg, offending_value))
    {
    }
    ParameterConstraintException(const char *msg, int offending_value)
        : std::runtime_error(build_error_msg(msg, offending_value))
    {
    }
    ParameterConstraintException(const char *msg, size_t offending_value)
        : std::runtime_error(build_error_msg(msg, offending_value))
    {
    }

  private:
    [[nodiscard]] static auto build_error_msg(const char *msg, double offending_value) -> std::string
    {
        std::stringstream ss;
        ss << "value " << offending_value << " violated constraint: " << msg;
        return ss.str();
    }
    [[nodiscard]] static auto build_error_msg(const char *msg, int offending_value) -> std::string
    {
        std::stringstream ss;
        ss << "value " << offending_value << " violated constraint: " << msg;
        return ss.str();
    }
    [[nodiscard]] static auto build_error_msg(const char *msg, size_t offending_value) -> std::string
    {
        std::stringstream ss;
        ss << "value " << offending_value << " violated constraint: " << msg;
        return ss.str();
    }
};

class MismatchException : public std::runtime_error
{
  public:
    MismatchException(const char *msg, double a, double b)
      : std::runtime_error(build_error_msg(msg, a, b))
    {
    }
    MismatchException(const char *msg, int a, int b)
      : std::runtime_error(build_error_msg(msg, a, b))
    {
    }
    MismatchException(const char *msg, size_t a, size_t b)
      : std::runtime_error(build_error_msg(msg, a, b))
    {
    }

  private:
    [[nodiscard]] static auto build_error_msg(const char *msg, double a, double b) -> std::string
    {
        std::stringstream ss;
        ss << "value mismatch (" << a << " != " << b <<  "):" << msg;
        return ss.str();
    }
    [[nodiscard]] static auto build_error_msg(const char *msg, int a, int b) -> std::string
    {
        std::stringstream ss;
        ss << "value mismatch (" << a << " != " << b <<  "):" << msg;
        return ss.str();
    }
    [[nodiscard]] static auto build_error_msg(const char *msg, size_t a, size_t b) -> std::string
    {
        std::stringstream ss;
        ss << "value mismatch (" << a << " != " << b <<  "):" << msg;
        return ss.str();
    }
};

} // namespace fatint::error
