/*
 * System-C TLM-2.0 remoteport ATS device.
 *
 * Copyright (c) 2021 Xilinx Inc
 * Written by Francisco Iglesias
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
  ********************************************************************************
 * Modifications:
 * Copyright (c) 2025 Renesas Electronics Corporation.
 * Modified by Masahiro Doi.
 *
 * Add PRINT function debug code for Remote-Port ATS test.
 *
 * These modifications are also released under the MIT License.
 */

#define SC_INCLUDE_DYNAMIC_PROCESSES

#include "systemc.h"
#include "tlm_utils/simple_initiator_socket.h"
#include "tlm_utils/simple_target_socket.h"
#include "remote-port-tlm-ats.h"
#include "tlm-extensions/atsattr.h"

// Added by Renesas Electronics for Remote-Port ATS Test
#ifdef ENABLE_RP_ATS_DEBUG
    #define PRINTF(...) do { printf(__VA_ARGS__); fflush(stdout); } while(0)
#else
    #define PRINTF(...) ((void)0)
#endif

remoteport_tlm_ats::remoteport_tlm_ats(sc_module_name name) :
    sc_module(name)
    , req("ats_req")
    , inv("ats_inv")
{
    req.register_b_transport(this, &remoteport_tlm_ats::b_transport);
}

void remoteport_tlm_ats::ats_invalidate(struct rp_pkt& pkt)
{
    PRINTF("remoteport_tlm_ats::ats_invalidate: START\n");
    sc_time                  delay(SC_ZERO_TIME);
    tlm::tlm_generic_payload gp;
    atsattr_extension*       atsattr = new atsattr_extension();

    gp.set_extension(atsattr);
    gp.set_command(tlm::TLM_IGNORE_COMMAND);

    gp.set_address(pkt.ats.addr);
    atsattr->set_length(pkt.ats.len);
    atsattr->set_attributes(pkt.ats.attributes);

    PRINTF("remoteport_tlm_ats::ats_invalidate: Invalidate details\n");
    
    PRINTF("\tcommand     = ");
    switch(gp.get_command()) {
        case tlm::TLM_READ_COMMAND:
            PRINTF("TLM_READ_COMMAND\n");
            break;
        case tlm::TLM_WRITE_COMMAND:
            PRINTF("TLM_WRITE_COMMAND\n");
            break;
        case tlm::TLM_IGNORE_COMMAND:
            PRINTF("TLM_IGNORE_COMMAND\n");
            break;
        default:
            PRINTF("UNKNOWN_COMMAND\n");
            break;
    }

    PRINTF("\taddress         = 0x%lx\n", pkt.ats.addr);
    PRINTF("\tlength          = 0x%lx\n", pkt.ats.len);
    PRINTF("\tattributes      = 0x%lx\n", pkt.ats.attributes);

    inv->b_transport(gp, delay);

    PRINTF("\tresponse status = %s\n", (gp.get_response_status() == tlm::TLM_OK_RESPONSE) ? "TLM_OK_RESPONSE" : "ERROR");

    assert(gp.get_response_status() == tlm::TLM_OK_RESPONSE);

    wait(delay);
    PRINTF("remoteport_tlm_ats::ats_invalidate: END\n");
}

void remoteport_tlm_ats::cmd_ats_inv_null(remoteport_tlm*     adaptor,
                                          struct rp_pkt&      pkt,
                                          bool                can_sync,
                                          remoteport_tlm_ats* dev)
{
    struct rp_pkt lpkt = pkt;
    int64_t       clk;
    size_t        plen;

    adaptor->sync->pre_ats_inv_cmd(pkt.sync.timestamp, can_sync);

    if(dev){
        dev->ats_invalidate(pkt);
    }

    clk  = adaptor->rp_map_time(adaptor->sync->get_current_time());
    plen = rp_encode_ats_inv(lpkt.hdr.id, lpkt.hdr.dev, &lpkt.ats, clk, lpkt.ats.attributes, lpkt.ats.addr, lpkt.ats.len, lpkt.ats.result, lpkt.hdr.flags | RP_PKT_FLAGS_response);

    adaptor->rp_write(&lpkt, plen);

    adaptor->sync->post_ats_inv_cmd(pkt.sync.timestamp, can_sync);
    
    if (dev) {
        dev->invalidate_false_event.notify();
    }
}

void remoteport_tlm_ats::tie_off(void)
{
    if(!req.size()){
        tieoff_req = new tlm_utils::simple_initiator_socket<remoteport_tlm_ats>();
        tieoff_req->bind(req);
    }
    if(!inv.size()){
        tieoff_inv = new tlm_utils::simple_target_socket<remoteport_tlm_ats>();
        inv.bind(*tieoff_inv);
    }
}

void remoteport_tlm_ats::b_transport(tlm::tlm_generic_payload& trans,
                                     sc_time&                  delay)
{
    PRINTF("remoteport_tlm_ats::b_transport: START\n");
    int64_t            clk = adaptor->rp_map_time(adaptor->sync->get_current_time());
    uint32_t           id  = adaptor->rp_pkt_id++;
    atsattr_extension* ats_attr;
    remoteport_packet  pkt_tx;
    unsigned int       ri;
    size_t             plen;
    uint32_t result;

    trans.get_extension(ats_attr);

    if(!adaptor->peer.caps.ats || !ats_attr){
        if(!adaptor->peer.caps.ats){
            PRINTF("remoteport_tlm_ats::b_transport - ATS capabiity is not supported\n");
        }
        else{
            PRINTF("remoteport_tlm_ats::b_transport - ATS capabiity is supported\n");
        }
        if(!ats_attr){
            PRINTF("remoteport_tlm_ats::b_transport - ATS extension is not supported\n");
        }
        else{
            PRINTF("remoteport_tlm_ats::b_transport - ATS extension is supported\n");
        }
        trans.set_response_status(tlm::TLM_GENERIC_ERROR_RESPONSE);
        PRINTF("remoteport_tlm_ats::b_transport: END\n");
        return;
    }

    pkt_tx.alloc(sizeof pkt_tx.pkt->ats);
    PRINTF("remoteport_tlm_ats::b_transport: Request\n");
    PRINTF("\tATS extension:\n");
    PRINTF("\t\taddress       = 0x%llx\n", (unsigned long long)trans.get_address());
    PRINTF("\t\tattribute     = 0x%llx\n", (unsigned long long)ats_attr->get_attributes());
    PRINTF("\t\tlength        = 0x%llx\n", (unsigned long long)ats_attr->get_length());
    PRINTF("\t\tresult        = 0x%x\n",                       ats_attr->get_result());
    plen = rp_encode_ats_req(id, dev_id, &pkt_tx.pkt->ats, clk, ats_attr->get_attributes(), trans.get_address(), ats_attr->get_length(), 0, 0);

    adaptor->rp_write(pkt_tx.pkt, plen);

    int retry_count = 0;
    const sc_time TIMEOUT(WAIT_TIMEOUT,SC_NS);

    ri = response_wait(id);

    if (resp[ri].pkt.pkt->hdr.id != id) {
        SC_REPORT_ERROR("ATS", "Response ID mismatch");
        trans.set_response_status(tlm::TLM_GENERIC_ERROR_RESPONSE);
        return;
    }

    result = resp[ri].pkt.pkt->ats.result;

    while ((result == RP_ATS_RESULT_invalidate || result == RP_ATS_RESULT_error) 
        && retry_count < MAX_RETRIES) {
        
        PRINTF("remoteport_tlm_ats::b_transport: Retry %d/%d (result=0x%" PRIx8 ")\n", 
            retry_count + 1, MAX_RETRIES, result);
        
        response_done(ri);
        
        // Wait for invalidate to complete
        if (result == RP_ATS_RESULT_invalidate) {
            this->invalidate = true;
            wait(TIMEOUT,invalidate_false_event);
        } else if (result == RP_ATS_RESULT_error){
            if (this->invalidate){
                wait(TIMEOUT,invalidate_false_event);
            }
        }
        //wait(SC_ZERO_TIME);
        
        // resend
        adaptor->rp_write(pkt_tx.pkt, plen);
        retry_count++;
        
        // get new response
        ri = response_wait(id);
        
        if (resp[ri].pkt.pkt->hdr.id != id) {
            SC_REPORT_ERROR("ATS", "Response ID mismatch in retry");
            trans.set_response_status(tlm::TLM_GENERIC_ERROR_RESPONSE);
            response_done(ri);
            return;
        }
        
        result = resp[ri].pkt.pkt->ats.result;
    }

    // timeout check
    if (result == RP_ATS_RESULT_invalidate || result == RP_ATS_RESULT_error) {
        SC_REPORT_ERROR("ATS", "Request timeout after maximum retries");
        trans.set_response_status(tlm::TLM_GENERIC_ERROR_RESPONSE);
        PRINTF("remoteport_tlm_ats::b_transport: TIMEOUT after %d retries (result=0x%" PRIx8 ")\n", 
            retry_count, result);
        response_done(ri);
        return;
    }

    if (this->invalidate) { 
        this->invalidate = false;
    }

    trans.set_address(resp[ri].pkt.pkt->ats.addr);
    ats_attr->set_attributes(resp[ri].pkt.pkt->ats.attributes);
    ats_attr->set_length(resp[ri].pkt.pkt->ats.len);
    ats_attr->set_result(resp[ri].pkt.pkt->ats.result);
    PRINTF("remoteport_tlm_ats::b_transport: Response\n");
    PRINTF("\tATS extension::\n");
    PRINTF("\t\taddress       = 0x%llx\n", (unsigned long long)trans.get_address());
    PRINTF("\t\tattribute     = 0x%llx\n", (unsigned long long)ats_attr->get_attributes());
    PRINTF("\t\tlength        = 0x%llx\n", (unsigned long long)ats_attr->get_length());
    PRINTF("\t\tresult        = 0x%x\n",                       ats_attr->get_result());
    // Give back the RP response slot.
    response_done(ri);

    trans.set_response_status(tlm::TLM_OK_RESPONSE);
    PRINTF("remoteport_tlm_ats::b_transport: END\n");
}


void remoteport_tlm_ats::cmd_ats_inv(struct rp_pkt& pkt,
                                     bool           can_sync)
{
    cmd_ats_inv_null(adaptor, pkt, can_sync, this);
}