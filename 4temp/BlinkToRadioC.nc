
#include <Timer.h>
#include "BlinkToRadio.h"

module BlinkToRadioC {
  uses interface Boot;
  uses interface Leds;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
}
implementation {
#define SAMPLING_FREQUENCY 100
  int16_t Receivecounter;
  int16_t Sendcounter;
  message_t pkt;
  bool busy = FALSE;
  int16_t TempData;
  Situation situation;

  void setLeds(uint16_t val) {
    if (val & 0x01)
      call Leds.led0On();
    else 
      call Leds.led0Off();
    if (val & 0x02)
      call Leds.led1On();
    else
      call Leds.led1Off();
    if (val & 0x04)
      call Leds.led2On();
    else
      call Leds.led2Off();
  }

  event void Boot.booted() {

    call AMControl.start();
  }


  event void AMControl.startDone(error_t err) {
    if (err != SUCCESS) {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
        setLeds(0x01);
    if (len == sizeof(BlinkToRadioMsg)) {

      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
      if(btrpkt->nodeid == 0x04){//看看是发给我这个温度节点的吗，是的时候才接收
          setLeds(btrpkt->nodeid);//灯亮是随机包的第二个亮
          Receivecounter = btrpkt->counter;//接收到node0的包
          Sendcounter = Receivecounter + 2000;//发送的是接收到的

          if (!busy) {
            BlinkToRadioMsg* btrpkt = 
    	        (BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToRadioMsg)));
            if (btrpkt == NULL) {//将数据装载
      	      return;
            }
            btrpkt->nodeid = TOS_NODE_ID;
            btrpkt->counter = Sendcounter;
            if (call AMSend.send(AM_BROADCAST_ADDR, 
            &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
                busy = TRUE;
            }
          }
      }
      else{
        setLeds(0x00);
      }
    }
    return msg;
  }
}

