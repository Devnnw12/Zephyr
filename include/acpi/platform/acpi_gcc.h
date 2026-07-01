#ifndef _ACPI_GCC_H
#define _ACPI_GCC_H

#ifndef va_arg
#ifdef ACPI_USE_SYSTEM_INCLUDES
typedef __builtin_va_list va_list;
#define va_start(ap, param)               __builtin_va_start(ap, param)
#define va_end(ap)                        __builtin_va_end(ap)
#define va_arg(ap, type)                  __builtin_va_arg(ap, type)
#define va_copy(dest, src)                __builtin_va_copy(dest, src)
#else
#include <stdarg.h>
#endif

#define ACPI_INLINE                           __inline__

#define ACPI_GET_FUNCTION_NAME()             __FUNC__

#define ACPI_PRINTF_LIKE(c)                  __attribute__((format(printf, c, c + 1)))

#define ACPI_UNUSED_VAR                      __attribute__((unused))

#define ACPI_UNUSED_VAR                      __attribute__((unused))

#define COMPILER_DEPENDENT_INT64             long long

#define ACPI_USE_NATIVE_MATH64

#endif /* _ACPI_GCC_H */