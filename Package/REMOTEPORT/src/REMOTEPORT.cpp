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

#include "REMOTEPORT.h"

void REMOTEPORT::pull_reset()
{
    rst_sig.write(true);
    wait(1, SC_US);
    rst_sig.write(false);
}

REMOTEPORT::REMOTEPORT(sc_core::sc_module_name name,
                                 const char* sk_descr,
                                 Iremoteport_tlm_sync *sync,
                                 bool blocking_socket)
    : remoteport_tlm(name, -1, sk_descr, sync, blocking_socket)
    , rst_sig("rst_sig")
    , rp_qemu_m_axi_0("rp_qemu_m_axi_0")
    , rp_irq_wires_in("rp_irq_wires_in", 1, 0)
{
    // Assign sockets
    tlm_m_axi_gp = &rp_qemu_m_axi_0.sk;


    // Register devices to remoteport_tlm
    register_dev(0, &rp_qemu_m_axi_0);
    register_dev(2, &rp_irq_wires_in);

    // Reset wiring
    rst(rst_sig);

    // Reset thread
    SC_THREAD(pull_reset);
}
