import controlP5.*;

class FireSensorsManager {
  ArrayList<FireSensorUnit> fireSensList;
  ControlP5 cp5;
  PApplet parent;
  int plotSizeY = height/5;
  public FireSensorsManager(PApplet parent) { //, int Nsensors
    fireSensList = new ArrayList<FireSensorUnit>();
    this.parent = parent;
    cp5 = new ControlP5(parent);
  }

  public void updateList(FireSensData fsData) {
    //println("Updating ID:"+fsData.ID);
    int foundPosition = positionOfElementWithID(fsData.ID);
    if (foundPosition != -1) {
      println("Element already on list, updating");
      fireSensList.get(foundPosition).update(fsData);
    } else {
      int newPositionOnList = fireSensList.size();
      fireSensList.add(new FireSensorUnit(fsData.ID-1, newPositionOnList));
      foundPosition = positionOfElementWithID(fsData.ID);
      fireSensList.get(foundPosition).update(fsData);
      addButton(fsData.ID, newPositionOnList);
      println("New Element on list, adding and updating");
    }
  }

  public void updateListBasedOnTimeOuts() {
    int foundPosition = -1;
    int ID = 0;
    for (FireSensorUnit fsUnit : fireSensList) {
      fsUnit.updateTimeOut();
      if (fsUnit.timeOut()) {
        foundPosition = positionOfElementWithID(fsUnit.getID());
        ID = fsUnit.getID();
      }
    }
    if (foundPosition != -1) {
      fireSensList.remove(foundPosition);
      cp5.getController("LED"+ID).remove();    
      println("Removing element #"+ID+" from list()");
      for (int index=0; index< fireSensList.size(); index++) {
        fireSensList.get(index).setPositionOnList(index);
        cp5.getController("LED"+fireSensList.get(index).getID()).setPosition(width*0.04, (index) * plotSizeY + plotSizeY*.1);
      }
    }
  }

  public void display() {
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

  private int positionOfElementWithID(int ID) {
    for (int index=0; index<fireSensList.size(); index++) {
      if (fireSensList.get(index).getID() == ID) {
        return index;
      }
    }
    return -1;
  }

  private void addButton(int ID, int positionOnList) {
    PFont font = createFont("Arial.ttf", height*0.025);
    cp5.addButton("LED"+ID)
      .setValue(ID)
      .setLabel("LED")
      .setFont(font)
      .setPosition(width*0.04, positionOnList * plotSizeY + plotSizeY*.1)
      .setSize(int(width*0.1), int(height*0.05));
  }
}
