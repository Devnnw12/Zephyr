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
   (defined ACPI_DUMP_APP)     || \
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

/* cofigurasi acpi_exec, multithreaded dengan full AML debugger */

#ifdef ACPI_EXEC_APP
#define ACPI_APPLICATION
#define ACPI_FULL_DEBUG
#define ACPI_MUTEX_DEBUG
#define ACPI_DEBUG_TRACK_ALLOCATIONS
#endif

/* configurasi acpi_help, peringatan error dimatikan */

#ifdef ACPI_HELP_APP
#define ACPI_NO_ERROR_MESSAGES
#endif

/* configurasi acpi_name, output debug dihidupkan */

#ifdef ACPI_NAMES_APP
#define ACPI_DEBUG_OUTPUT
#endif

/* configurasi acpi_main, dengan multithreaded full dari AML debugger */

#ifdef ACPI_MAIN_APP
#define ACPI_APPLICATION
#define ACPI_FULL_DEBUG
#define ACPI_MUTEX_DEBUG
#define ACPI_TRACK_ALLOCATION 1
#define ACPI_USE_NATIVE_MEMORY_MAPPING
#endif

/* configurasi dari acpi_exec/acpi_name/acpi_main/example. menggunakan native RSDP */

#if (defined ACPI_EXEC_APP)      || \
    (defined ACPI_EXAMPLE_APP)   || \
    (defined ACPI_MAIN_APP)      || \
    (defined ACPI_NAMES_APP)
#define ACPI_USE_NATIVE_RSDP_POINTER
#endif

/* configurasi acpi_dump. menggunakan penanda natural yang dimiliki host */

#ifdef ACPI_DUMP_APP
#define ACPI_USE_NTIVE_MEMORY_MAPPING
#endif

/* configurasi acpi_name/example. hardware dimatikan */

#if (defined ACPI_EXAMPLE_APP)   || \
    (defined ACPI_MAIN_APP)      || \
    (defined ACPI_NAMES_APP)
#define ACPI_REDUCED_HARDWARE 1
#endif

/* menyatukan APICA library. dua versi, salah satunya full debug */

#ifdef ACPI_LIBRARY
#define ACPI_USE_LOCAL_CACHE
#define ACPI_DEBUGGER 1
#define ACPI_DIASSEMBLER 1

#ifdef _DEBUG
#define ACPI_DEBUG_OUTPUT
#endif
#endif

/* Umum untuk semua aplikasi ACPICA */

#ifdef ACPI_APPLICATION
#define ACPI_LOCAL_CACHE
#endif

/* mendukung debug/assembler umum */

#ifdef ACPI_FULL_DEBUG
#define ACPI_DEBUG_OUTPUT
#define ACPI_DEBUGGER 1
#define ACPI_DISASSEMBLER 1
#endif

#define ACPI_SRC_OS_LF_ONLY 0