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
#include <greensocs/gsutils/luafile_tool.h>



SysC_Island_MIT::SysC_Island_MIT(
    const sc_core::sc_module_name& module_name)
: sc_core::sc_module(module_name)
, p_bus_lenient("bus_lenient", true, "bus lenient property")
, m_broker({})
, m_originator()
, m_broker_handle(cci::cci_get_broker())
, m_bus("m_bus")
, irq_sig("irq_sig")
, p_remoteport_socket_path("virt_socket_path", "NULL", "virt_socket_path")
, p_shared_mem_path_00("shared_mem_path_00", "NULL", "shared_mem_path_00")
, p_shared_mem_size_00("shared_mem_size_00", 0x80000, "shared_mem_size_00")
{

    m_pl011 = new vcml::serial::pl011("pl011");
    m_uart_term = new vcml::serial::terminal("uart_term");
    m_clock_uart = new vcml::generic::clock("clock_uart", 3686400 * vcml::Hz);
    m_reset = new vcml::generic::reset("reset");


    m_bus.rst.stub();
    m_bus.clk.stub();

    setup_pl011();

    setup_connection();

    setup_shared_memory();
}

SysC_Island_MIT::~SysC_Island_MIT() {
    delete m_pl011;
    delete m_uart_term;
}

void SysC_Island_MIT::setup_pl011() {


    bind_ts(m_pl011->in);

    m_uart_term->serial_tx.bind(m_pl011->serial_rx);
    m_uart_term->serial_rx.bind(m_pl011->serial_tx);

    // // Bind to stub for signal of vcml::component
    m_clock_uart->clk.bind(m_pl011->clk);
    m_reset->rst.bind(m_pl011->rst);

}

void SysC_Island_MIT::setup_connection() {
    std::string sock("0");
    sock = p_remoteport_socket_path.get_value();
    std::cout << "Creating REMOTEPORT with socket: "<< "  "<< p_remoteport_socket_path.name() << sock.c_str() << std::endl;
    // Create REMOTEPORT
    m_remoteport = std::make_shared<REMOTEPORT>("REMOTEPORT", sock.c_str(), nullptr, true);

    // Bind to BUS
    bind_is(*m_remoteport->tlm_m_axi_gp);

    // IRQ wires
    m_pl011->irq.bind(irq_sig);
    (m_remoteport->rp_irq_wires_in.wires_in[0])(irq_sig);

    m_remoteport->tie_off();
}

void SysC_Island_MIT::setup_shared_memory()
{
    shared_mem_id = shm_open(p_shared_mem_path_00.get_value().c_str(), O_CREAT | O_RDWR, 0777);
    if (shared_mem_id == -1)
    {
        perror("Fail to open shared memory");
    }
    if (ftruncate(shared_mem_id, p_shared_mem_size_00) == -1)
    {
        perror("Fail to ftruncate shared memory");
    }
}


