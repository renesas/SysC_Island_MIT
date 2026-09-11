/******************************************************************************
 *                                                                            *
 * Copyright (C) 2025 Renesas Electronics Corporation                         *
 * All Rights Reserved                                                        *
 *                                                                            *
 * SPDX-License-Identifer: BSD-3-Clause                                       *
 *                                                                            *
 * This work is licensed under the terms described in the LICENSE file        *
 * found in the root directory of this source tree.                           *
 *                                                                            *
 ******************************************************************************/

#ifndef SYSC_ISLAND_MIT_HPP_
#define SYSC_ISLAND_MIT_HPP_

#include <cci_configuration>

#include "systemc.h"
#include <greensocs/gsutils/cciutils.h>
#include <greensocs/gsutils/luafile_tool.h>

#include "tlm.h"
#include <vcml.h>

#include <utility>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

#include "tlm_utils/simple_target_socket.h"
#include "tlm_utils/simple_initiator_socket.h"
#include <string>
#include <thread>
#include "REMOTEPORT.h"


template <unsigned int BUSWIDTH> class TlmInitiatorSocket;


class SysC_Island_MIT: public sc_core::sc_module {

public:
    struct SAddressInfo
    {
        uint64_t start;
        uint64_t size;
        uint64_t end;
        uint64_t offset;
        bool is_mirror;
    };

    vcml::serial::pl011* m_pl011;
    vcml::serial::terminal* m_uart_term;
    vcml::generic::clock* m_clock_uart;
    vcml::generic::reset* m_reset;

    vcml::generic::bus m_bus;
    sc_signal<bool> irq_sig;
    sc_signal<sc_dt::uint64> m_pll01_dum_clk_sig;
    sc_signal<bool> m_pll01_dum_rst_sig;

    std::vector<vcml::module*> m_bus2Ip_adapters;

    gs::ConfigurableBroker m_broker;

    cci::cci_param<bool> p_bus_lenient;
    cci::cci_param<std::string> p_remoteport_socket_path;

    cci::cci_param<std::string> p_shared_mem_path_00;
    cci::cci_param<uint64_t> p_shared_mem_size_00;

    std::unordered_map<std::string, cci::cci_param_untyped*> cci_params;
    cci::cci_originator m_originator;
    cci::cci_broker_handle m_broker_handle;

    int shared_mem_id;

    std::shared_ptr<REMOTEPORT> m_remoteport;

    void setup_pl011();

    void setup_connection();

    void setup_shared_memory();

    bool GetAddressInfo(std::string sockname, SAddressInfo& info, std::string originator_name)
    {
        if (originator_name.empty()) {
            originator_name = this->name();
        }
        // if sockname ends ".in", add "_".
        if(sockname.substr(sockname.size() - 3) == ".in")
        {
            sockname += "_";
        }
        // start address
        if(!m_broker.has_preset_value(sockname + ".address"))
        {
            // error.
            std::stringstream log("0");
            log << "Error: Can't find " << sockname << ".address.";
            SC_REPORT_WARNING("GetAddressInfo", log.str().c_str());
            return false;
        }
        auto addressvalue = m_broker.get_preset_cci_value(sockname + ".address");
        uint64_t address = 0;
        address =  addressvalue.get_uint64();
        std::string param_name("0");
        param_name = sockname + ".address";
        if (param_name.rfind(originator_name, 0) == 0) {
            param_name = param_name.substr(originator_name.length() + 1);
        }
        cci_params[param_name] = new cci::cci_param<uint64_t>(param_name, address, this->m_broker_handle, "", cci::CCI_RELATIVE_NAME, this->m_originator);
        m_broker.lock_preset_value(sockname + ".address");
        m_broker.ignore_unconsumed_preset_values(
            [sockname](const std::pair<std::string, cci::cci_value>& iv) -> bool {return iv.first==(sockname + ".address");}
        );
        // size
        if(!m_broker.has_preset_value(sockname + ".size"))
        {
            // error.
            std::stringstream log("0");
            log << "Error: Can't find " << sockname << ".size.";
            SC_REPORT_WARNING("GetAddressInfo", log.str().c_str());
            return false;
        }
        auto sizevalue = m_broker.get_preset_cci_value(sockname + ".size");
        uint64_t size = 0;
        size = sizevalue.get_uint64();
        param_name = sockname + ".size";
        if (param_name.rfind(originator_name, 0) == 0) {
            param_name = param_name.substr(originator_name.length() + 1);
        }
        cci_params[param_name] = new cci::cci_param<uint64_t>(param_name, size, this->m_broker_handle, "", cci::CCI_RELATIVE_NAME, this->m_originator);
        m_broker.lock_preset_value(sockname + ".size");
        m_broker.ignore_unconsumed_preset_values(
            [sockname](const std::pair<std::string, cci::cci_value>& iv) -> bool {return iv.first==(sockname + ".size");}
        );
        // offset
        uint64_t offset = 0;
        if(m_broker.has_preset_value(sockname + ".offset")){
            auto offsetvalue = m_broker.get_preset_cci_value(sockname + ".offset");
            offset = offsetvalue.get_uint64();
            param_name = sockname + ".offset";
            if (param_name.rfind(originator_name, 0) == 0) {
                param_name = param_name.substr(originator_name.length() + 1);
            }
            cci_params[param_name] = new cci::cci_param<uint64_t>(param_name, offset, this->m_broker_handle, "", cci::CCI_RELATIVE_NAME, this->m_originator);
            m_broker.lock_preset_value(sockname + ".offset");
            m_broker.ignore_unconsumed_preset_values(
                [sockname](const std::pair<std::string, cci::cci_value>& iv) -> bool {return iv.first==(sockname + ".offset");}
            );
        }
        
        info.start = address;
        info.size = size;
        info.end = address + size -1;
        info.offset = offset;
        return true;
    }

    template<unsigned int BUSWIDTH>
    void bind_is(tlm::tlm_initiator_socket<BUSWIDTH>& socket)
    {
        m_bus.bind(socket);
    }

    template<typename MODULE, typename TYPES = tlm::tlm_base_protocol_types, unsigned int BUSWIDTH>
    void bind_is(tlm_utils::simple_initiator_socket_b<MODULE, BUSWIDTH, TYPES, sc_core::SC_ZERO_OR_MORE_BOUND>& socket, size_t type = 0)
    {
        std::string name = vcml::mkstr("busadapter_%s_%lu", socket.basename(), m_bus2Ip_adapters.size());
        vcml::tlm_bus_width_adapter<BUSWIDTH, 32>* busadapter = new vcml::tlm_bus_width_adapter<BUSWIDTH, 32>(name.c_str());
        m_bus2Ip_adapters.push_back(busadapter);
        socket.bind(busadapter->in);
        m_bus.bind(busadapter->out);
    }

    template<unsigned int BUSWIDTH>
    void bind_ts(tlm::tlm_target_socket<BUSWIDTH>& socket, const std::string &originator_name = "")
    {
        SAddressInfo info{0};
        GetAddressInfo(socket.name(), info, originator_name);
        m_bus.bind(socket, {info.start, info.end}, info.offset);
    }


    explicit SysC_Island_MIT(const sc_core::sc_module_name& module_name);
    ~SysC_Island_MIT() override;

    // Disable copying
    SysC_Island_MIT(const SysC_Island_MIT&)            = delete;
    auto operator=(const SysC_Island_MIT&) = delete;

    // Disable moving
    SysC_Island_MIT(SysC_Island_MIT&&)                 = delete;
    auto operator=(SysC_Island_MIT&&)      = delete;

    SC_HAS_PROCESS(SysC_Island_MIT);

};

#endif // SYSC_ISLAND_MIT_HPP_