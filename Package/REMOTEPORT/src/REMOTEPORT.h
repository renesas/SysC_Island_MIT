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

#ifndef __REMOTEPORT_H__
#define __REMOTEPORT_H__

#include "systemc.h"
#include "tlm_utils/simple_initiator_socket.h"
#include "tlm_utils/simple_target_socket.h"

#include "remote-port-tlm.h"
#include "remote-port-tlm-wires.h"
#include "remote-port-tlm-memory-master.h"
#include "remote-port-tlm-memory-slave.h"
#include "remote-port-tlm-ats.h"

class REMOTEPORT : public remoteport_tlm
{
public:
    // Devices
    remoteport_tlm_memory_master rp_qemu_m_axi_0;

    remoteport_tlm_wires         rp_irq_wires_in;

    // Sockets exposed to outer modules
    tlm_utils::simple_initiator_socket<remoteport_tlm_memory_master> *tlm_m_axi_gp;



    SC_HAS_PROCESS(REMOTEPORT);

    REMOTEPORT(sc_core::sc_module_name name,
                    const char* sk_descr,
                    Iremoteport_tlm_sync *sync = nullptr,
                    bool blocking_socket = false);

    void pull_reset();

private:
    sc_signal<bool> rst_sig;
};

#endif
