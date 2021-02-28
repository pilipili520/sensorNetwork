
#include <Timer.h>
#include "BlinkToRadio.h"

module BlinkToRadioC {
  uses interface Boot;
  uses interface Leds;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface Random;
  uses interface SplitControl as AMControl;
uses interface Read<uint16_t> as readTemp;
//uses interface Read<uint16_t> as readPhoto;
uses interface Timer<TMilli> as SampleTimer;
}
implementation {//实现这些接口提供的事件处理函数
#define SAMPLING_FREQUENCY 1000
  int16_t Receivecounter;
  int16_t Sendcounter;
  message_t pkt;
  bool busy = FALSE;
  int16_t TempData;
  int16_t HumidityData;
  int16_t PhotoData;
  Situation situation;
  int16_t tmpnode;
  int cnt = -1;

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
    call SampleTimer.startPeriodic(SAMPLING_FREQUENCY);//1000ms触发一次
  }

  event void SampleTimer.fired()
	{
    cnt++;
		call readTemp.read();//读取温度值
  if(cnt < 60){
        Sendcounter = situation.temperature ;//第一个1min发送温度
        setLeds(0x04);//第二个灯亮
        tmpnode = 0x04;
      }
  else if(cnt >= 60){//第二个1min发送随机数
	    
      if(cnt == 120){
        cnt = -1;
      }
      if(cnt >= 60){
        Sendcounter = ((call Random.rand16()) % 100) ;//包里填随机数
        tmpnode = 0x02;
        setLeds(tmpnode);
      }
  }
  if (!busy) {//btrptk和pkt指向同一块内存空间,这里实现发送
      BlinkToRadioMsg* btrpkt = 
	    (BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToRadioMsg)));
      if (btrpkt == NULL) {
	      return;
      }
      btrpkt->nodeid = tmpnode;

      btrpkt->counter = Sendcounter;
      //下面是发送的函数
      if (call AMSend.send(tmpnode, 
          &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
        busy = TRUE;
      }
    }
	}

  event void readTemp.readDone(error_t result, uint16_t val) {
		if (result == SUCCESS){
			val = -40.1+ 0.01*val;//转换成摄氏度值，这个公式根据SHT11数据手册
			TempData = val;
		}
		else TempData = 0xffff;
		situation.temperature = TempData;
		call Leds.led0Toggle();

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

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){//node0并没有用到但是可能也要实现这个事件，接收到后自动触发
    if (len == sizeof(BlinkToRadioMsg)) {
      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
      //setLeds(btrpkt->counter);
      Receivecounter = btrpkt->counter;
      
    }
    return msg;
  }
   
}




