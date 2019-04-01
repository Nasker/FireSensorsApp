import controlP5.*;

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
        .setPosition(width*0.04, (ID-1) * plotSizeY + plotSizeY*.1)
        .setSize(int(width*0.1), int(height*0.05))
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
