class FireSensorUnit { //<>//
  int ID;
  boolean timeOut;
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
  color tempColor = color(255, 0, 0);
  color humColor = color(0, 255, 0);
  float currentTemperature;
  float currentHumidity;
  PFont font;

  public FireSensorUnit(int receivedID, int positionOnList) {
    this.ID = receivedID + 1;
    timeOut = false;
    this.plotPosY = positionOnList * plotSizeY;
    //println("ID: "+ this.ID +" Drawing offset: "+ plotPosY);
    temperatureList = new FloatList();
    humidityList = new FloatList();
    font = createFont("Arial.ttf", height*0.025);
    textFont(font);
  }
  
  public int getID(){
    return ID;
  }
  
  public void setPositionOnList(int positionOnList){
    this.plotPosY = positionOnList * plotSizeY;
  }

  public void update(FireSensData fsData) {
    lastTimeOut = millis();
    timeOut = false;
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
      timeOut = true;
    }
    else timeOut = false;
  }
  public boolean timeOut() {
    return timeOut;
  }
  public void displayPlotBackground() {
    fill(56);
    rect(plotPosX, plotPosY, plotSizeX, plotSizeY);
  }

  public void displayPlotLines() {
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

  public void displayPlotLayout() {
    strokeWeight(2);
    stroke(255);
    noFill();
    rect(plotPosX, plotPosY, plotSizeX, plotSizeY);
  }

  public void displayStatsText() {
    fill(255);
    text("ID: "+ID, width*0.04, plotPosY + plotSizeY*.5);
      fill(tempColor);
      String tempText = String.format("%.1f", currentTemperature);
      text("T: "+tempText+"ºC", width*0.04, plotPosY + plotSizeY*.7);
      fill(humColor);
      String humText = String.format("%.1f", currentHumidity);
      text("H: "+humText+"%", width*0.04, plotPosY + plotSizeY*.9);
  }

  private int calcValueHeight(float rawValue) {
    return int(map(rawValue, 0, 100, plotSizeY, 0)) + plotPosY;
  }
}
