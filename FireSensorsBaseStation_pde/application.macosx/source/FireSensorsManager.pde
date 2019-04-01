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
