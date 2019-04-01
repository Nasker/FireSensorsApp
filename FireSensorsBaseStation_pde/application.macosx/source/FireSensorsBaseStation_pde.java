import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import processing.serial.*; 
import java.nio.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class FireSensorsBaseStation_pde extends PApplet {

FireSensorium fSensorium;
int Nsensors = 2;
String portName = "/dev/tty.usbmodem000000001";

public void setup() {
  
  
  fSensorium = new FireSensorium(this, portName, Nsensors);
}

public void draw() {
  fSensorium.update();
  fSensorium.display();
}
class FireSensData {
  public int ID;
  public float temperature;
  public float humidity;
  
  public FireSensData(int ID, float temperature, float humidity) {
    this.ID = ID;
    this.temperature = temperature;
    this.humidity = humidity;
  }
}
class FireSensorUnit {
  int ID;
  boolean active;
  int timeOutLength = 10000;
  long lastTimeOut = 0;
  FloatList temperatureList;
  FloatList humidityList;
  int plotStrokeWeight = 2;
  int tableSize = width-width/5;
  int plotSizeX = tableSize;
  int plotSizeY = height/5;
  int plotPosX = width/5 - plotStrokeWeight;
  int plotPosY;
  int pyTemp = 0;
  int pyHum = 0;
  int iteration = 0;
  int tempColor = color(255, 0, 0);
  int humColor = color(0, 255, 0);
  float currentTemperature;
  float currentHumidity;
  PFont font;

  public FireSensorUnit(PApplet parent, int receivedID) {
    this.ID = receivedID + 1;
    active = false;
    this.plotPosY = receivedID * plotSizeY;
    //println("ID: "+ this.ID +" Drawing offset: "+ plotPosY);
    temperatureList = new FloatList();
    humidityList = new FloatList();
    font = createFont("Arial.ttf", 25);
    textFont(font);
  }

  public void update(FireSensData fsData) {
    active = true;
    lastTimeOut = millis();
    temperatureList.append(fsData.temperature);
    humidityList.append(fsData.humidity);
    iteration++;
    if (iteration >= tableSize) {
      temperatureList.remove(0);
      humidityList.remove(0);
    }
    //println(iteration);
    for (float value : temperatureList)
      //print(value + " ");
      //println();
      currentTemperature = temperatureList.get(temperatureList.size()-1);
    currentHumidity = humidityList.get(humidityList.size()-1);
  }

  public void updateTimeOut() {
    if (millis() > lastTimeOut + timeOutLength) {
      active = false;
    }
  }

  public void displayPlotBackground() {
    if (active) {
      fill(56);
      rect(plotPosX, plotPosY, plotSizeX, plotSizeY);
    }
  }

  public void displayPlotLines() {
    if (active) {
      strokeWeight(2);
      for (int i = 0; i < temperatureList.size(); i++) { 
        stroke(tempColor);
        int yTemp = calcValueHeight(temperatureList.get(i));
        line(i+plotPosX, pyTemp, i+1+plotPosX, yTemp);
        pyTemp = yTemp;
        stroke(humColor);
        int yHum = calcValueHeight(humidityList.get(i));
        line(i+plotPosX, pyHum, i+1+plotPosX, yHum);
        pyHum = yHum;
      }
    }
  }

  public void displayPlotLayout() {
    if (active) {
      strokeWeight(2);
      stroke(255);
      noFill();
      rect(plotPosX, plotPosY, plotSizeX, plotSizeY);
    }
  }

  public void displayStatsText() {
    if (active) {
      fill(255);
      text("ID: "+ID, width*0.04f, plotPosY + plotSizeY*.5f);
      if (active) {
        fill(tempColor);
        String tempText = String.format("%.1f", currentTemperature);
        text("T: "+tempText+"ºC", width*0.04f, plotPosY + plotSizeY*.7f);
        fill(humColor);
        String humText = String.format("%.1f", currentHumidity);
        text("H: "+humText+"%", width*0.04f, plotPosY + plotSizeY*.9f);
      }
    }
  }

  private int calcValueHeight(float rawValue) {
    return PApplet.parseInt(map(rawValue, 0, 100, plotSizeY, 0)) + plotPosY;
  }
}


FireSerialManager fsSerialManager;

class FireSensorium {
  FireSensorsManager fsManager;
  FireSensData fsData;
  ControlP5 cp5;
  int plotSizeY = height/5;
  String serialPortName;
  PApplet parent;
  int Nsensors;


  public FireSensorium(PApplet parent, String serialPortName, int Nsensors) {
    this.parent = parent;
    this.serialPortName = serialPortName;
    this.Nsensors = Nsensors;
    this.fsManager = new FireSensorsManager(parent, this.Nsensors);
    fsSerialManager = new FireSerialManager(this.parent, this.serialPortName);
    this.fsData = new FireSensData(0, 0, 0);
    initGUI();
  }

  public void update() {
    if (fsSerialManager.receiveDataFromSensor(fsData))
      fsManager.updateList(fsData);
  }

  public void display() {
    fsManager.display();
  }

  private void initGUI() {
    cp5 = new ControlP5(parent);
    for (int ID = 1; ID <= Nsensors; ID++) {
      cp5.addButton("SEND TO SENSOR #"+ID)
        .setValue(ID)
        .setPosition(width*0.04f, (ID-1) * plotSizeY + plotSizeY*.1f)
        .setSize(PApplet.parseInt(width*0.1f), PApplet.parseInt(height*0.05f))
        ;
    }
  }
}

public void controlEvent(ControlEvent theEvent) {
  String controllerName = theEvent.getController().getName();
  int ID = Integer.parseInt(controllerName.substring(controllerName.length()-1, controllerName.length()));
  println("Button pressed from sensor with ID: "+ ID);
  fsSerialManager.sendCommandToSensor(ID);
}
class FireSensorsManager {
  ArrayList<FireSensorUnit> fireSensList;
  public FireSensorsManager(PApplet parent, int Nsensors) {
    fireSensList = new ArrayList<FireSensorUnit>();
    for (int ID = 0; ID < Nsensors; ID++) {
      fireSensList.add(new FireSensorUnit(parent, ID));
    }
  }

  public void updateList(FireSensData fsData) {
    fireSensList.get(fsData.ID-1).update(fsData);
  }

  public void display() {
    for (FireSensorUnit fsUnit : fireSensList) {
      fsUnit.updateTimeOut();
    }
    background(0);
    for (FireSensorUnit fsUnit : fireSensList) {
      fsUnit.displayPlotBackground();
    }
    for (FireSensorUnit fsUnit : fireSensList) {
      fsUnit.displayPlotLines();
    }
    for (FireSensorUnit fsUnit : fireSensList) {
      fsUnit.displayPlotLayout();
    }
    for (FireSensorUnit fsUnit : fireSensList) {
      fsUnit.displayStatsText();
    }
  }
}



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
    print("Sending serial data: ");
    for(byte sentByte:sentData) print(sentByte+ " ");
    println();
  }

  private float byteArrayToFloat(int data[]) {
    int outBits = data[0] << 24 | (data[1] & 0xFF) << 16 | (data[2] & 0xFF) << 8 | (data[3] & 0xFF);
    return Float.intBitsToFloat(outBits);
  }
}
  public void settings() {  size(1000, 1000);  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "FireSensorsBaseStation_pde" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
