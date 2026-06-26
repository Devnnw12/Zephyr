#ifdef __ACPI_ENVIRONMENT_H__
#define __ACPI_ENVIRONMENT_H__

// tipe untuk ACPI_MUTEX_TYPE
#define ACPI_BINARY_SEMAPHONE    0
#define ACPI_OSL_MUTEX           1

// tipe untuk DEBUGGING_THREADING
#define DEBUGGER_SINGLE_THREAD   0
#define DEBUGGER_MULTI_THREAD    1

// configurasi pengapplikasian
#if (defined ACPI_ASL_COMPILER) || \
   (defined ACPI_BIN_APP)      || \
   (defined ACPI_BIN_APP)      || \
   (defined ACPI_DUMB_APP)     || \
   (defined ACPI_HELP_APP)     || \
   (defined ACPI_NAMES_APP)    || \
   (defined ACPI_SRC_APP)      || \
   (defined ACPI_MAIN_APP)     || \
   (defined ACPI_XTRACT_APP)   || \
	(defined ACPI_EXAMPLE_APP)  || \
	(defined ACPI_EFI_HELLO)
#define ACPI_APPLICATION
#define ACPI_SINGLE_THREAD
#define USE_NATIVE_ALOCATED_ZEROED
#endif

// configurasi iASL
#ifdef ACPI_ASL_COMPILER
#define ACPI_DEBUG_OUTPUT
#define ACPI_CONSTANT_EVALUATION_ONLY
#define ACPI_LARGE_NAMESPACE_NODE
#define ACPI_DATA_TABLE_DIASSEMBLY
#define ACPI_32BIT_PHYSICAL_ADDRESS
#define ACPI_DIASSEMBLER 1
#endif

/**/