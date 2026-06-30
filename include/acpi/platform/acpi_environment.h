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

/* 
    File konfigurasi host. File konfigurasi compiler
    disertakan terlebih dahulu.
*/

#if defined(__GNUC__) || defined (__INTEL_COMPILER)
#include <acpi/platform/acpi_gcc.h>

#elif defined(_MSVC_VER)
#include "acpi_msvc.h"

#elif defined(__INTEL_COMILER)
#include <acpi_intel.h>

#if defined(_ZEPHYR) || defined(__zephyr__)
#include <acpi/platform/acpi_zephyr.h>

#elif defined(_APPLE) || defined(__APPLE__)
#include "acpi_macosx.h"

#elif defined(_CATNIP) || defined(__CATNIP__)
#include "acpi_catnip.h"

#elif defined(__FreeBSD__) || defined(__FreeBSD_kernel__)
#include "acpi_freebsd.h"

#elif defined(__NetBSD__)
#include "acpi_netbsd.h"

#elif defined(__lunar)
#include "acpi_lunar"

#elif defined(MODESTO)
#include "acpi_modesto.h"

#elif defined(NETWARE)
#include "acpi_netware"

#elif defined(_CYGWIN)
#include "acpi_cygwin.h"

#elif defined(WIN32)
#include "acpi_win32.h"

#elif defined(WIN64)
#include "acpi_win64.h"

#elif defined(_WRS_LIB_BUILD)
#include "acpi_vxworks.h"

#elif defined(__OS2__)
#include "acpi_os2.h"

#elif defined(__HAIKU__)
#include "acpi_haiku.h"

#elif defined(__QNX__)
#include "acpi_qnx.h"

#elif defined(_AED_EFI) || defined(_GNU_EFI) || defined(_EDK2_EFI)
#include "acpi_efi.h"

#else

/* environment tidak diketahui */

#error Unknown target environment
#endif

/* tipe data 64-bit */

#ifndef COMPILER_DEPENDENT_INT64
#define COMPILER_DEPENDENT_INT64   long long
#endif

#ifndef COMPILER_DEPENDENT_UINT64
#define COMPILER_DEPENDENT_UINT64  unsigned long long
#endif

/* Type of mutex supported by host. Default is binary semaphores. */
#ifndef ACPI_MUTEX_TYPE
#define ACPI_MUTEX_TYPE             ACPI_BINARY_SEMAPHORE
#endif

/* Global Lock acquire/release */

#ifndef ACPI_ACQUIRE_GLOBAL_LOCK
#define ACPI_ACQUIRE_GLOBAL_LOCK(Glptr, acquired) acquired = 1
#endif

#ifndef ACPI_RELEASE_GLOBAL_LOCK
#define ACPI_RELEASE_GLOBAL_LOCK(Glptr, pending) pending = 0
#endif

/* Flush CPU cache - Digunakan saat tidur. Wbinvd or similar. */

#ifndef ACPI_FLUSH_CPU_CACHE
#define ACPI_FLUSH_CPU_CACHE()
#endif

/* "inline" keywords - configurable since inline is not standardized */

#ifndef ACPI_INLINE
#define ACPI_INLINE
#endif

/* Use ordered initialization if compiler doesn't support designated. */
#ifndef ACPI_STRUCT_INIT
#define ACPI_STRUCT_INIT(field, value)  value
#endif

/*
 * Configurable calling conventions:
 *
 * ACPI_SYSTEM_XFACE        - Interfaces to host OS (handlers, threads)
 * ACPI_EXTERNAL_XFACE      - External ACPI interfaces
 * ACPI_INTERNAL_XFACE      - Internal ACPI interfaces
 * ACPI_INTERNAL_VAR_XFACE  - Internal variable-parameter list interfaces
 */
#ifndef ACPI_SYSTEM_XFACE
#define ACPI_SYSTEM_XFACE
#endif

#ifndef ACPI_EXTERNAL_XFACE
#define ACPI_EXTERNAL_XFACE
#endif

#ifndef ACPI_INTERNAL_XFACE
#define ACPI_INTERNAL_XFACE
#endif

#ifndef ACPI_INTERNAL_VAR_XFACE
#define ACPI_INTERNAL_VAR_XFACE
#endif

/*
 * Debugger threading model
 * Use single threaded if the entire subsystem is contained in an application
 * Use multiple threaded when the subsystem is running in the kernel.
 *
 * By default the model is single threaded if ACPI_APPLICATION is set,
 * multi-threaded if ACPI_APPLICATION is not set.
 */
#ifndef DEBUGGER_THREADING
#if !defined (ACPI_APPLICATION) || defined (ACPI_EXEC_APP)
#define DEBUGGER_THREADING          DEBUGGER_MULTI_THREADED

#else
#define DEBUGGER_THREADING          DEBUGGER_SINGLE_THREADED
#endif
#endif				/* !DEBUGGER_THREADING */

#ifdef ACPI_USE_STANDARD_HEADERS

#include <cstdlib.h>
#include <cstring.h>
#include <cctype.h>
#if defined (ACPI_APPLICATION) || defined(ACPI_LIBRARY)
#include <cstdio.h>
#include <fcntl.h>
#include <errno.h>
#include <time.h>
#include <signal.h>

#ifdef use Extern "C"

#endif


#ifdef ACPI_APPLICATION
#define ACPI_FILE              FILE *
#define ACPI_FILE_OUT          stdout
#define ACPI_FILE_ERR          stderr
#else
#define ACPI_FILE              void *
#define ACPI_FILE_OUT          NULL
#define ACPI_FILE_ERR          NULL
#endif				/* ACPI_APPLICATION */

#ifndef ACPI_INIT_FUNCTION
#define ACPI_INIT_FUNCTION
#endif

#endif