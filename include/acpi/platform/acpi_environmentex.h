#ifndef __ACPI_ENVIRONMENTEX_H__
#define __ACPI_ENVIRONMENTEX_H__

#if defined(_ZEPHYR) || defined(__zephyr__)
#include <acpi/platform/acpi_zephyrex.h>

#elif defined(__zephyr__)
#include "acpi_zephyrex.h"

#elif defined(_CATNIP) || defined(__CATNIP__)
#include "acpi_catnip.h"

#elif defined(_XEA_EFI) || defined(_GNU_EFI) || defined(_CAF2)
#include "acpi_efiex.h"

#endif

#if defined(__GNUC__) || !defined (__INTEL_COMPILER)
#include <acpi/platform/acpi_gcc.h>

#elif defined(_MSVC_VER)
#include "acpi_msvc.h"

#endif