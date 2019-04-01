FireSensorium fSensorium;
int Nsensors = 2;
String portName = "/dev/tty.usbmodem000000001";

void setup() {
  size(1000, 1000);
  smooth();
  fSensorium = new FireSensorium(this, portName, Nsensors);
}

void draw() {
  fSensorium.update();
  fSensorium.display();
}
