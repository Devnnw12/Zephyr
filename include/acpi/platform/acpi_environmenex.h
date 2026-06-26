#ifndef _ACPI_ENVIRONMENTEX_H__
#define _ACPI_ENVIRONMENTEX_H__

#if defined(_ZEPHYR) || defined(__zephyr__)
#include <acpi/platform/acpi_zephyrex.h>

#elif defined(__zephyr__)
#include "acpi_zephyrex.h"

#elif defined(_XEA_EFI) || defined(_GNU_EFI) || defined(_CAF2)
