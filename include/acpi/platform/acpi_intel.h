#ifndef _ACPI_INTEL_H_
#define _ACPI_INTEL_H_

#ifndef va_arg
#include <stdarg.h>
#endif

#define COMPILER_DEPENDENT_INT64     __int64
#define COMPILER_DEPENDENT_UINT64    unsigned __int64
#define COMPILER_DEPENDENT_INT32     int
#define COMPILER_DEPENDENT_UINT32    unsigned int
#endif

#define ACPI_SYSTEM_XFACE
#define ACPI_EXTERNAL_XFACE
#define ACPI_INTERNAL_XFACE
#define ACPI_INTERNAL_VAR_XFACE

#pragma warning(disable: 4115) /* named type definition in parentheses */

#pragma warning(disable: 4201) /* nonstandard extension used : nameless struct/union */

#pragma warning(disable: 4214) /* nonstandard extension used : bit field types other than int */

#pragma warning(disable: 4204) /* nonstandard extension used : non-constant aggregate initializer */

#pragma warning(disable: 4057) /* indirection to slightly different base types */

#endif /* _ACPI_INTEL_H_ */