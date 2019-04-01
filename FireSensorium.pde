FireSerialManager fsSerialManager;

class FireSensorium {
  FireSensorsManager fsManager;
  FireSensData fsData;
  String serialPortName;
  PApplet parent;
  
  public FireSensorium(PApplet parent, String serialPortName) {//, int Nsensors
    this.parent = parent;
    this.serialPortName = serialPortName;
    //this.Nsensors = Nsensors;
    this.fsManager = new FireSensorsManager(parent);//, this.Nsensors
    fsSerialManager = new FireSerialManager(this.parent, this.serialPortName);
    this.fsData = new FireSensData(0, 0, 0);
    
  }

  public void update() {
    fsManager.updateListBasedOnTimeOuts();
    if (fsSerialManager.receiveDataFromSensor(fsData))
      fsManager.updateList(fsData);
  }

  public void display() {
    fsManager.display();
  }
}

public void controlEvent(ControlEvent theEvent) {
  String controllerName = theEvent.getController().getName();
  int ID = Integer.parseInt(controllerName.substring(controllerName.length()-1, controllerName.length()));
  println("Button pressed from sensor with ID: "+ ID);
  fsSerialManager.sendCommandToSensor(ID);
}
