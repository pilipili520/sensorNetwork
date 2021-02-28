
#ifndef TEST_SERIAL_H
#define TEST_SERIAL_H


enum {
  AM_BLINKTORADIO = 6,
  TIMER_PERIOD_MILLI = 250
};

typedef nx_struct BlinkToRadioMsg {
  nx_int16_t nodeid;
  nx_int16_t counter;
} BlinkToRadioMsg;



typedef nx_struct test_serial_msg {
  nx_int16_t counter;
} test_serial_msg_t;

enum {
  AM_TEST_SERIAL_MSG = 0x89,
};

#endif
