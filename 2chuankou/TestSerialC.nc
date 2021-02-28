#include "Timer.h"
#include "TestSerial.h"
#include "printf.h"

module TestSerialC {
  uses {
    interface SplitControl as SerialControl;
    interface Leds;
    interface Boot;
    interface Receive as SerialReceive;
    interface AMSend as SerialAMSend;
    interface Packet as SerialPacket;
    interface Packet as RadioPacket;
    interface AMPacket as RadioAMPacket;
    interface SplitControl as RadioAMControl;  
    interface AMSend as RadioAMSend;
    interface Receive as RadioReceive; 
  }
}
implementation {

  message_t packet;//数据包
  bool busy = FALSE;
  message_t pkt;
  bool locked = FALSE;//节点是否忙
  int16_t Radiocounter = 0;
  int16_t Serialcounter = 0;//数据包计数
  
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
    call RadioAMControl.start();
    call SerialControl.start(); //开始，向下找startDone
  }
  //接收数据程序，接收到数据后三位设置led灯
  event message_t* SerialReceive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {//收到PC的吧，目前不用管的
    if (len != sizeof(test_serial_msg_t)) {return bufPtr;}
    else {//设置数据包
      test_serial_msg_t* rcm = (test_serial_msg_t*)payload;
      setLeds(rcm->counter);
      Serialcounter = rcm->counter;
      return bufPtr;
    }
  }

  event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(BlinkToRadioMsg)) {//收到普通节点的
      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
      setLeds(btrpkt->nodeid);//2是温度，一灯亮
      Radiocounter = btrpkt->counter;//这个是温度
      //回至电脑
    if (locked) {
      return;
    }
    else {
      test_serial_msg_t* rcm = (test_serial_msg_t*)call SerialPacket.getPayload(&packet, sizeof(test_serial_msg_t));
      if (rcm == NULL) {return;}
      if (call SerialPacket.maxPayloadLength() < sizeof(test_serial_msg_t)) {
	      return;
      }

      rcm->counter = Radiocounter;
      if (call SerialAMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(test_serial_msg_t)) == SUCCESS)
      {
	      locked = TRUE;
      }
    }

    }
    return msg;
  }

  event void SerialAMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;//发送成功，节点空闲
    }
  }

  event void RadioAMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }


  event void SerialControl.startDone(error_t err) {
    if (err != SUCCESS) {
      call SerialControl.start();//开始成功
    }
  }

  event void RadioAMControl.startDone(error_t err) {
    if (err != SUCCESS) {
      call RadioAMControl.start();
    }
  }

  event void SerialControl.stopDone(error_t err) {}//结束成功

  event void RadioAMControl.stopDone(error_t err) {}
}





