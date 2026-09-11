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

#include "Memory.hpp"
#include "SysC_Island_MIT.hpp"
#include <iostream>

using namespace vcml;

Memory::Memory(const sc_core::sc_module_name& n)
    : sc_core::sc_module(n)
    ,global_broker(cci::cci_get_broker()) 
{

    create_mem("shared_mem_00", false, 0x80000);
}

Memory::~Memory() {

}

void Memory::create_mem(const std::string& name, bool readonly, u64 size) {

    auto mem = std::make_shared<generic::memory>(name.c_str(), size, readonly);
    mMemory_vector.push_back(mem);
}

void Memory::bind_mem(void* p_systemc_island) {
    SysC_Island_MIT* island = static_cast<SysC_Island_MIT*>(p_systemc_island);

    for (auto& mem : mMemory_vector) {

        island->bind_ts(mem->in);
        mem->clk.stub();
        mem->rst.stub();
    }
}
