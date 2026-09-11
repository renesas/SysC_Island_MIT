/******************************************************************************
 *                                                                            *
 * Copyright (C) 2025 Renesas Electronics Corporation                         *
 * All Rights Reserved                                                        *
 *                                                                            *
 * SPDX-License-Identifier: BSD-3-Clause                                      *
 *                                                                            *
 * This work is licensed under the terms described in the LICENSE file        *
 * found in the root directory of this source tree.                           *
 *                                                                            *
 ******************************************************************************/


#include "SysC_Island_MIT.hpp"
#include "Memory.hpp"
#include <systemc>
#include <dlfcn.h>
#include <string>

#include "vcml-cci.h"
#include <vcml.h>

int sc_main(int argc, char *argv[])
{
    sc_report_handler::set_actions(SC_ERROR, SC_DEFAULT_WARNING_ACTIONS);
    std::string sci_lua_path("0");

    if (argc > 0){
       for (int count = 1; count + 1 < argc; count++) {
            std::string_view arg("0");
            arg = argv[count];
            if (arg == "--luafile_with_sysc_island_mit") {
                sci_lua_path = std::string(argv[count + 1]);
            }
        }
    }

    // create global broker
    cci_utils::broker global_broker("Global Broker");
    cci::cci_register_broker(&global_broker);

    vcml::cci::broker vcml_cci_broker("vcml_cci_broker");

    LuaFile_Tool SysC_Island_MIT_lua{ "SysC_Island_MIT_lua", "" };
    SysC_Island_MIT_lua.config(sci_lua_path.c_str());

    std::shared_ptr<SysC_Island_MIT> p_sysc_island_mit = std::make_shared<SysC_Island_MIT>("SysC_Island_MIT");

    std::shared_ptr<Memory> p_mem = std::make_shared<Memory>("Memory");


    p_mem->bind_mem(static_cast<void*>(p_sysc_island_mit.get()));

    auto start = std::chrono::system_clock::now();

        std::cout << "Simulation without Python API" << std::endl;
            vcml::system sys("system");
            sys.run();

    auto end = std::chrono::system_clock::now();

    auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(end - start);
    std::cout << "Simulation Time: " << sc_core::sc_time_stamp().to_seconds() << "SC_SEC" << std::endl;
    std::cout << "Simulation Duration: " << elapsed.count() << "s (Wall Clock)" << std::endl;

    return 0;
}