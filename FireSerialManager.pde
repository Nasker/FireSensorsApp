import processing.serial.*;
import java.nio.*;

class FireSerialManager {
  Serial serialPort;
  int serialReading[];
  final int inputNBytes = 16;
  final int outputNBytes = 3;

  public FireSerialManager(PApplet parent, String portName) {
    println("Available ports:");
    printArray(Serial.list());
    serialPort = new Serial(parent, portName);
    println("Starting communication with port: "+ portName);
    serialReading = new int[inputNBytes];
  }

  public boolean receiveDataFromSensor(FireSensData fireSensData) {
    fireSensData.ID = -1;
    if ( serialPort.available() > 0) {
      for (int i=0; i< serialReading.length; i++) {
        serialReading[i] = serialPort.read();
      }
      if (serialReading[9] == 255) { 
        fireSensData.ID = serialReading[0];
        fireSensData.temperature = byteArrayToFloat(subset(serialReading, 1, 4));
        fireSensData.humidity = byteArrayToFloat(subset(serialReading, 5, 4));
        println("-ID: "+ fireSensData.ID +"\t-Temp: " + fireSensData.temperature + "ºC\t-Humidity:" + fireSensData.humidity + "%");
      }
    }
    return fireSensData.ID != -1;
  }

  public void sendCommandToSensor(int ID) {
    byte sentData[] = new byte[outputNBytes];
    sentData[0] = (byte)0xAA;
    sentData[1] = (byte)ID;
    sentData[2] = (byte)0xFF;
    serialPort.write(sentData);
    /*print("Sending serial data: ");
    for(byte sentByte:sentData) print(sentByte+ " ");
    println();*/
  }

  private float byteArrayToFloat(int data[]) {
    int outBits = data[0] << 24 | (data[1] & 0xFF) << 16 | (data[2] & 0xFF) << 8 | (data[3] & 0xFF);
    return Float.intBitsToFloat(outBits);
  }
}
