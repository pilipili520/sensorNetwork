COMPONENT=TestSerialAppC
BUILD_EXTRA_DEPS += TestSerial.class
CLEAN_EXTRA = *.class TestSerialMsg.java

CFLAGS += -I$(TOSDIR)/lib/T2Hack
CFLAGS += -DCC2420_DEF_CHANNEL=23
CFLAGS += -DCC2420_DEF_RFPOWER=9
CFLAGS += -DENABLE_PR
CFLAGS += -I$(TOSDIR)/lib/printf


TestSerial.class: $(wildcard *.java) TestSerialMsg.java
	javac -target 1.4 -source 1.4 *.java

TestSerialMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=TestSerialMsg TestSerial.h test_serial_msg -o $@


include $(MAKERULES)

