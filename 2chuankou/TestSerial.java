import java.io.IOException;
import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;
import java.util.Scanner;

public class TestSerial implements MessageListener {

  private MoteIF moteIF;
  
  public TestSerial(MoteIF moteIF) {
    this.moteIF = moteIF;
    this.moteIF.registerListener(new TestSerialMsg(), this);
  }

  public void sendPackets(int flag) {//pc向节点发送
   
  }
//接收节点向计算机发送的数据，MessageListener的实现
  public void messageReceived(int to, Message message) {
    TestSerialMsg msg = (TestSerialMsg)message;
    int tmp = msg.get_counter();
    if((tmp / 1000) == 2)
      System.out.println("Received data from node 1 and temperature :" + ( tmp % 1000));
    else if((tmp / 1000) == 4){
      System.out.println("Received data from node 2 and RanNumber :" + ( tmp % 1000));
    }
  }
  
  private static void usage() {
    System.err.println("usage: TestSerial [-comm <source>]");
  }
    //调用程序，传入参数
  public static void main(String[] args) throws Exception {
    String source = null;
    if (args.length == 2) {
      if (!args[0].equals("-comm")) {
	usage();//提示信息,提取命令行参数，基于字符串匹配
	System.exit(1);
      }
      source = args[1];
    }
    else if (args.length != 0) {
      usage();
      System.exit(1);
    }
    
    PhoenixSource phoenix;
    
    if (source == null) {
      phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
    }
    else {
      phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);//连接串口
    }

    MoteIF mif = new MoteIF(phoenix);//设置节点
    TestSerial serial = new TestSerial(mif);
  }
}

