#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H//枚举全局变量
enum {
  AM_BLINKTORADIO = 6,//指明AMSenderC组件的AM标识号
  TIMER_PERIOD_MILLI = 250//时间定时
};
//定义数据包结构
typedef nx_struct BlinkToRadioMsg {
  nx_int16_t nodeid;
  nx_int16_t counter;
} BlinkToRadioMsg;
//数据结构成员
typedef nx_struct Situation {
nx_int16_t temperature;
nx_int16_t light;
nx_int16_t humidity;
nx_int16_t number1;
nx_int16_t number2;
nx_int16_t number3;
} Situation;
 
#endif
