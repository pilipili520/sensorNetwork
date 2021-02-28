#include "TestSerial.h"

configuration TestSerialAppC {}
implementation {
  components TestSerialC as App, LedsC, MainC;
  components ActiveMessageC as Radio, SerialActiveMessageC as Serial;
  components new AMSenderC(AM_BLINKTORADIO);
  components new AMReceiverC(AM_BLINKTORADIO);

  App.Boot -> MainC.Boot;
  App.SerialControl -> Serial;
  App.SerialReceive -> Serial.Receive[AM_TEST_SERIAL_MSG];
  App.SerialAMSend -> Serial.AMSend[AM_TEST_SERIAL_MSG];
  App.Leds -> LedsC;
  App.SerialPacket -> Serial;
  App.RadioPacket -> AMSenderC;
  App.RadioAMPacket -> AMSenderC;
  App.RadioAMControl -> Radio;  
  App.RadioAMSend -> AMSenderC;
  App.RadioReceive -> AMReceiverC;

}








