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

#ifndef MEMORY_HPP_
#define MEMORY_HPP_

#include <string>
#include <vector>
#include <memory>
#include <systemc>
#include <vcml.h>
#include <cci_configuration>
#include <vcml/models/generic/memory.h>

class SysC_Island_MIT; 

class Memory : public sc_core::sc_module {
public:

    std::vector<std::shared_ptr<vcml::generic::memory>> mMemory_vector;


    explicit Memory(const sc_core::sc_module_name& n);
    ~Memory() override;

    // Disable copying
    Memory(const Memory&)            = delete;
    auto operator=(const Memory&) = delete;

    // Disable moving
    Memory(Memory&&)                 = delete;
    auto operator=(Memory&&)      = delete;


    void create_mem(const std::string& name, bool readonly, vcml::u64 size);


    void bind_mem(void* p_systemc_island);
    
private:
    cci::cci_broker_handle global_broker;
};

#endif // MEMORY_HPP_