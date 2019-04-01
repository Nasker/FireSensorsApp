FireSensorium fSensorium;
int Nsensors = 5;

void setup() {
  size(1000, 1000);
  smooth();
  fSensorium = new FireSensorium(this, "/dev/tty.usbmodem000000001", Nsensors);
}

void draw() {
  fSensorium.update();
  fSensorium.display();
}
