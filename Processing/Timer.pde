class Timer {
  
  int time;// in ms
  
  Timer() {
    time = 0;
  }
  
  public void start() {
      time = millis();
  }
  
  public int getTime() {
    return millis() - time;
  }
  
  public int getTime(String type) {
    if (type.equals("s")) {
      return (millis() - time) / 1000;
    } 
    return millis() - time;
  }
  
  public String getStringTime() {
    if (time == 0) {
      return "00:00";
    } else {
      int sec_int =  getTime("s");
      String min = "" + (sec_int / 60);
      if (min.length() == 1) {
        min = "0" + min;
      }
      String sec = "" + (sec_int % 60);
      if (sec.length() == 1) {
        sec = "0" + sec;
      }
      return min + ":" + sec;
    } 
  }
  
}
