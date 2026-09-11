/******************************************************************************
 *                                                                            *
 * Copyright (C) 2022 MachineWare GmbH                                        *
 * All Rights Reserved                                                        *
 *                                                                            *
 * This is work is licensed under the terms described in the LICENSE file     *
 * found in the root directory of this source tree.                           *
 *                                                                            *
 ******************************************************************************/

#ifndef VCML_VERSION_H
#define VCML_VERSION_H

#define VCML_VERSION_MAJOR    2025
#define VCML_VERSION_MINOR    4
#define VCML_VERSION_PATCH    29

#define VCML_GIT_REV          "nogit"
#define VCML_GIT_REV_SHORT    "nogit"

#define VCML_VERSION          20250429
#define VCML_VERSION_STRING   "vcml-2025.04.29-nogit"

#include <mwr.h>

MWR_DECLARE_MODULE(VCML, "vcml", "Apache-2.0");

#endif
