import controlP5.*;
import processing.serial.*;
import java.util.*;

ControlP5 cp;

PFont pfont20, pfont15, pfont48, pfont35, pfont12;

RadioButton r1;
Button a, b, d, e, f, g;
ScrollableList c;
Textarea txtArea;
Println console;

int width = 700;
int height = 700;

String portName = null;
String[] path = null;
Serial myPort = null;

boolean simulating = false;
boolean streaming = false;
String[] gcode;
int i = 0;

boolean absolute = true;
boolean zeroPos = false;

float jog = 0.1;

float penSize =0.5;

String textValue = "";

int simSpeed;
int startTime;

int maxX = 38;
int maxY = 38;

float xPos = 0;
float yPos = 0;
float zPos = 1;
float xPrevPos = 0;
float yPrevPos = 0;
float zPrevPos = 0;
float xDiff = 0;
float yDiff = 0;

void openSerialPort()
{
  if (portName == null) return;
  if (myPort != null) myPort.stop();

  myPort = new Serial(this, portName, 9600);

  myPort.bufferUntil('\n');
}

void setup() {
  background(0);  
  size(700, 730);
  rect(20, 20, 450, 450);

  cp = new ControlP5(this);
  pfont12 = loadFont("Ebrima-12.vlw");
  pfont20 = loadFont("Roboto-Medium-20.vlw");
  pfont15 = loadFont("Roboto-Medium-15.vlw");
  pfont35 = loadFont("Roboto-Medium-35.vlw");
  pfont48 = loadFont("Roboto-Medium-48.vlw");
  ControlFont font20 = new ControlFont(pfont20, 20);
  ControlFont font15 = new ControlFont(pfont15, 15);
  fill(255);  

  cp.addButton("pX")    
    .setPosition(620, 245)
    .setSize(55, 55)
    .setFont(font20)
    .setCaptionLabel("+X");
  ;

  cp.addButton("nX")    
    .setPosition(500, 245)
    .setSize(55, 55)
    .setFont(font20)
    .setCaptionLabel("-X");
  ;

  cp.addButton("pY")
    .setPosition(620, 185)
    .setSize(55, 55)
    .setFont(font20)
    .setCaptionLabel("+Y");
  ;

  cp.addButton("nY")
    .setPosition(500, 305)
    .setSize(55, 55)
    .setFont(font20)
    .setCaptionLabel("-Y");
  ;

  cp.addButton("up")
    .setPosition(560, 185)
    .setSize(55, 55)
    .setFont(font20)
    .setCaptionLabel("+Z");
  ;

  cp.addButton("down")
    .setPosition(560, 305)
    .setSize(55, 55)
    .setFont(font20)
    .setCaptionLabel("-Z");
  ;

  g = cp.addButton("zero")    
    .setPosition(620, 305)
    .setSize(55, 55)
    .setFont(font20)
    .setCaptionLabel("0");
  ;
  g.getCaptionLabel().toUpperCase(false);

  PImage[] homeImg = {loadImage("home.png"), loadImage("home_h.png"), loadImage("home_d.png")};
  cp.addButton("home")    
    .setPosition(560, 245)
    .setImages(homeImg)
    .setSize(55, 55)
    ;

  f = cp.addButton("absrel")    
    .setPosition(500, 185)
    .setFont(font20)
    .setCaptionLabel("Abs")
    .setSize(55, 55)
    ; 
  f.getCaptionLabel().toUpperCase(false);


  r1 = cp.addRadioButton("rButton")
    .setPosition(500, 380)
    .setSize(25, 25)
    .setItemsPerRow(3)
    .setSpacingColumn(35)          
    .addItem("0.1", 1)
    .addItem("0.5", 2)
    .addItem("1.0", 3)          
    .activate(0)
    ;
  for (Toggle t : r1.getItems()) {
    t.getCaptionLabel().setFont(font15);
  }  

  b = cp.addButton("browse")
    .setValue(0)
    .setPosition(605, 580)      
    .setSize(70, 30)
    .setFont(font15)
    .setCaptionLabel("Browse")
    .setId(0)
    ;
  b.getCaptionLabel().toUpperCase(false);

  c = cp.addScrollableList("port")
    .setPosition(605, 540)
    .setSize(70, 90)
    .setBarHeight(30)
    .setItemHeight(30)
    .addItems(Serial.list())
    .setFont(font15)
    .setCaptionLabel("Port")
    .close()
    ;
  c.getCaptionLabel().toUpperCase(false);   

  cp.addTextfield("maxXSize")
    .setPosition(605, 425)
    .setSize(70, 30)
    .setFont(font15)
    .setValue(str(maxX))
    .setCaptionLabel("")
    .setAutoClear(false)
    ;

  cp.addTextfield("maxYSize")
    .setPosition(605, 460)
    .setSize(70, 30)
    .setFont(font15)
    .setValue(str(maxY))
    .setCaptionLabel("")
    .setAutoClear(false)
    ;

  cp.addTextfield("textValue")
    .setPosition(605, 500)
    .setSize(70, 30)
    .setFont(font15)
    .setCaptionLabel("")
    .setValue(str(penSize))
    .setAutoClear(false)    
    ; 

  a = cp.addButton("stream")    
    .setPosition(500, 635)      
    .setSize(55, 30)
    .setFont(font15)
    .setCaptionLabel("Stream")
    .setId(1)
    ;
  a.getCaptionLabel().toUpperCase(false);

  d = cp.addButton("clearB")    
    .setPosition(560, 635)      
    .setSize(45, 30)
    .setFont(font15)
    .setCaptionLabel("Clear")    
    ;
  d.getCaptionLabel().toUpperCase(false);

  e = cp.addButton("simulate")    
    .setPosition(610, 635)   
    .setSize(65, 30)
    .setFont(font15)
    .setCaptionLabel("Simulate")
    .setId(2);
  ;
  e.getCaptionLabel().toUpperCase(false);

  cp.addTextfield("input")
    .setPosition(20, 490)
    .setSize(390, 30)
    .setFont(font15)
    .setCaptionLabel("")
    ;

  cp.addButton("send")    
    .setPosition(420, 490)      
    .setSize(50, 30)
    .setFont(font15)
    ;

  txtArea = cp.addTextarea("txt")
    .setPosition(20, 540)
    .setSize(449, 169)
    .setFont(pfont12)
    .setLineHeight(14)
    .setColor(color(255))
    .setColorBackground(color(0, 45, 90))              
    ;
  console = cp.addConsole(txtArea);

  cp.addSlider("slider")
    .setPosition(500, 690)
    .setSize(175, 20)
    .setRange(0, 200)
    .setValue(50)
    .setFont(font15)
    .setCaptionLabel("")
    ;
}

void draw() {  
  fill(0);
  rect(470, 0, 230, 730);
  fill(255);

  //labels
  textFont(pfont15); 
  text("Max X", 500, 280+165);
  text("Max Y", 500, 315+165);
  text("Pen Size", 500, 355+165);
  text("Port", 500, 395+165);
  text("Select Gcode", 500, 435+165);
  text("Simulation speed", 500, 685);
  if (path != null) {
    text(path[path.length-1], 500, 465+160);
  }

  //plot
  drawLine();

  //position
  textFont(pfont48);
  text("X", 500, 55);
  text("Y", 500, 105);
  text("Z", 500, 155);
  fill(0, 45, 90);
  stroke(0, 113, 220);
  rect(560, 20, 115, 35);
  rect(560, 70, 115, 35);
  rect(560, 120, 115, 35);
  noStroke();
  fill(0, 113, 220);
  rect(19, 539, 451, 171);
  fill(255);
  textFont(pfont35);
  textAlign(RIGHT);
  text(String.format("%.2f", xPos - xDiff), 670, 50);
  text(String.format("%.2f", yPos - yDiff), 670, 100);
  text(String.format("%.2f", zPos), 670, 150);
  textAlign(LEFT);

  //penSize
  textValue = cp.get(Textfield.class, "textValue").getText();
  if (textValue == null || textValue.trim().length() == 0 || float(textValue) <= 0 || parseFloat(textValue) != parseFloat(textValue)) {
    println("Invalid pen Size!");
  } else {
    penSize = parseFloat(textValue);
  }

  //maxX/YSize
  textValue = cp.get(Textfield.class, "maxXSize").getText();
  if (textValue == null || textValue.trim().length() == 0 || int(textValue) <= 0 || parseInt(textValue) != parseInt(textValue)) {
    println("Invalid max X size!");
  } else {
    maxX = parseInt(textValue);
  }
  textValue = cp.get(Textfield.class, "maxYSize").getText();
  if (textValue == null || textValue.trim().length() == 0 || int(textValue) <= 0 || parseInt(textValue) != parseInt(textValue)) {
    println("Invalid max Y size!");
  } else {
    maxY = parseInt(textValue);
  }

  //simulation call
  if (simulating == true) {
    sim();
  }

  //update port list
  if (c.isOpen() == true) {
    cp.get(ScrollableList.class, "port").setItems(Serial.list());
  } 

  //coordinates system
  stroke(color(255, 0, 0));  
  line(30, 460, 60, 460);
  strokeWeight(1);
  line(60, 460, 50, 455);
  line(60, 460, 50, 465);
  textFont(pfont15);
  fill(color(255, 0, 0));
  text("X", 65, 465);
  stroke(color(0, 255, 0));
  line(30, 460, 30, 430);
  line(30, 430, 25, 440);
  line(30, 430, 35, 440);
  fill(color(0, 255, 0));
  text("Y", 26, 425);
  fill(255);
  noStroke();
}

public void controlEvent(ControlEvent theEvent) {
  switch(theEvent.getId()) {
    case(0):
    browseB();      
    break;
    case(1):
    streamB();
    break;
    case (2):
    simulateB();
    break;
  }
}

public void port(int n) {
  Map<String, Object> portData = new HashMap<String, Object>();
  portData = cp.get(ScrollableList.class, "port").getItem(n);
  portName = portData.get("text").toString();
  println(portName);
  openSerialPort();
}

public void zero() {
  if (myPort != null && !streaming && zeroPos == false) {
    xDiff = xPos;
    yDiff = yPos;
    zeroPos = true;
    g.setCaptionLabel("  Abs\ncoord");
    g.getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP);
  } else if (myPort != null && !streaming && zeroPos == true) {
    xDiff = 0;
    yDiff = 0;
    zeroPos = false;
    g.setCaptionLabel("0");
    g.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  } else if (myPort == null && !streaming) {
    println("Select a COM port!");
  }
} 

public void up() {
  if (myPort != null && !streaming) {
    myPort.write("M300 S50\n");
    print("M300 S50\n");    
    zPos = 1;
  } else if (myPort == null && !streaming) {
    println("Select a COM port!");
  }
}

public void down() {   
  if (myPort != null && !streaming) {
    myPort.write("M300 s30\n");
    print("M300 s30\n");
    zPos = 0;
  } else if (myPort == null && !streaming) {
    println("Select a COM port!");
  }
}

public void home() {
  if (myPort != null && !streaming) {
    myPort.write("G90\nG00 X0.000 Y0.000 Z0.000\n");
    print("G90\nG00 X0.000 Y0.000 Z0.000\n");
    xPos = 0;
    yPos = 0;
  } else if (myPort == null && !streaming) {
    println("Select a COM port!");
  }
}

public void pX() {
  if (myPort != null && !streaming) {
    if (absolute == true) {
      myPort.write("G91\nG00 X" + jog + " Y0.000 Z0.000\nG90\n");
      print("G91\nG00 X" + jog + " Y0.000 Z0.000\nG90\n");
    } else {
      myPort.write("G91\nG00 X" + jog + " Y0.000 Z0.000\nG91\n");
      print("G91\nG00 X" + jog + " Y0.000 Z0.000\nG91\n");
    }
    xPos = xPos + jog;
  } else if (myPort == null && !streaming) {
    println("Select a COM port!");
  }
}

public void nX() {
  if (myPort != null && !streaming) {
    if (absolute == true) {
      myPort.write("G91\nG00 X-" + jog + " Y0.000 Z0.000\nG90\n");
      print("G91\nG00 X-" + jog + " Y0.000 Z0.000\nG90\n");
    } else {
      myPort.write("G91\nG00 X-" + jog + " Y0.000 Z0.000\nG91\n");
      print("G91\nG00 X-" + jog + " Y0.000 Z0.000\nG91\n");
    }
    xPos = xPos - jog;
  } else if (myPort == null && !streaming) {
    println("Select a COM port!");
  }
}

public void pY() {
  if (myPort != null && !streaming) {
    if (absolute == true) {
      myPort.write("G91\nG00 X0.000 Y" + jog + " Z0.000\nG90\n");
      print("G91\nG00 X0.000 Y" + jog + " Z0.000\nG90\n");
    } else {
      myPort.write("G91\nG00 X0.000 Y" + jog + " Z0.000\nG91\n");
      print("G91\nG00 X0.000 Y" + jog + " Z0.000\nG91\n");
    }
    yPos = yPos + jog;
  } else if (myPort == null && !streaming) {
    println("Select a COM port!");
  }
}

public void nY() {
  if (myPort != null && !streaming) {
    if (absolute == true) {
      myPort.write("G91\nG00 X0.000 Y-" + jog + " Z0.000\nG90\n");
      print("G91\nG00 X0.000 Y-" + jog + " Z0.000\nG90\n");
    } else {
      myPort.write("G91\nG00 X0.000 Y-" + jog + " Z0.000\nG91\n");
      print("G91\nG00 X0.000 Y-" + jog + " Z0.000\nG91\n");
    }
    yPos = yPos - jog;
  } else if (myPort == null && !streaming) {
    println("Select a COM port!");
  }
}

public void absrel() {
  if (absolute == true && myPort != null && !streaming) {
    myPort.write("G91\n");
    print("G91\n");
    f.setCaptionLabel("Rel");
    absolute = false;
  } else if (absolute == false && myPort != null && !streaming) {
    myPort.write("G90\n");
    print("G90\n");
    f.setCaptionLabel("Abs");
    absolute = true;
  } else if (myPort == null && !streaming) {
    println("Select a COM port!");
  }
}

public void rButton(int rB) {
  switch(rB) {
  case 1: 
    jog = 0.1;
    break;
  case 2: 
    jog = 0.5;
    break;
  case 3: 
    jog = 1;
    break;
  }
}

public void input(String theText) {  
  send();
}

public void maxX() {
}

public void maxY() {
}

public void send() {
  if (myPort != null && !streaming) {
    myPort.write(cp.get(Textfield.class, "input").getText() + '\n');
    println(cp.get(Textfield.class, "input").getText());
    processLine(cp.get(Textfield.class, "input").getText() + '\n');
    cp.get(Textfield.class, "input").clear();
  } else if (myPort == null) {
    println("Select a COM port!");
  }
}

public void browseB() {
  if (!streaming) {
    gcode = null; 
    i = 0;
    File file = null;     
    selectInput("Select a gCode to process:", "gcodeSelect", file);
  }
}

public void streamB() {
  if (gcode != null && myPort != null && !streaming) {
    streaming = true;
    a.setCaptionLabel("Stop");
    stream();
  } else if (gcode != null && myPort != null && streaming) {
    streaming = false;
    a.setCaptionLabel("Stream");
  } else if (gcode == null && myPort != null && !streaming) {
    println("Select gcode file!");
  } else if (gcode != null && myPort == null && !streaming) {
    println("Select COM port!");
  } else if (gcode == null && myPort == null && !streaming) {
    println("Select COM port and gcode file!");
  }
}

public void clearB() {
  background(0);
  rect(20, 20, 450, 450);
}

void drawLine() {
  if (zPos == 1) {
    stroke(color(0, 255, 0));
    strokeWeight(1);
    line(round(xPrevPos/maxX*450+20), round(-(yPrevPos/maxY*450+20)+490), round(xPos/maxX*450+20), round(490-(yPos/maxY*450+20)));
    noStroke();
  } else {
    stroke(0);
    strokeWeight(penSize*450/maxX);
    line(round(xPrevPos/maxX*450+20), round(-(yPrevPos/maxY*450+20)+490), round(xPos/maxX*450+20), round(490-(yPos/maxY*450+20)));
    strokeWeight(1);
    noStroke();
  }
  xPrevPos = xPos;
  yPrevPos = yPos;
  zPrevPos = zPos;
}

public void simulateB() {
  if (gcode != null && !simulating) {
    simulating = true;
    e.setCaptionLabel("Stop"); 
    startTime = millis();
    sim();
  } else if (gcode != null && simulating) {
    simulating = false;
    e.setCaptionLabel("Simulate");
  } else if (gcode == null && !simulating) {
    println("Select gcode file!");
  }
} 

public void sim() {
  if (simSpeed == 0) {
    for (int k=i; i < gcode.length; i++) {
      if (gcode[i].trim().length() == 0) continue;
      else {
        processLine(gcode[i] + '\n');    
        drawLine();
      }
    }
    simulating = false;
    e.setCaptionLabel("Simulate");
    i = 0;
    return;
  } else if (millis() > startTime + simSpeed) {
    while (true) {
      if (i == gcode.length) {
        simulating = false;
        e.setCaptionLabel("Simulate");
        i = 0;
        return;
      }
      if (gcode[i].trim().length() == 0) i++;
      else break;
    }  
    println(gcode[i]);
    processLine(gcode[i] + '\n');    
    drawLine();
    i++;
    startTime = millis();
  }
}    

void slider(int val) {
  simSpeed = val;
}

void serialEvent(Serial p)
{
  String s = p.readStringUntil('\n');
  println(s.trim());

  if (s.trim().startsWith("ok")) stream();
  if (s.trim().startsWith("error")) streaming = false;
}

void stream()
{
  if (!streaming) return;

  while (true) {
    if (i == gcode.length) {
      streaming = false;
      a.setCaptionLabel("Stream");
      i = 0;
      return;
    }

    if (gcode[i].trim().length() == 0) i++;
    else break;
  }

  println(gcode[i]);
  myPort.write(gcode[i] + '\n');
  processLine(gcode[i] + '\n');
  i++;
}

public void processLine(String line) {   
  char c;
  char[] cLine;
  char[] outputLine = new char[512];
  boolean lineIsComment = false;
  boolean lineSemiColon = false;  
  int lIdx = 0;
  line = line.toUpperCase();
  cLine = line.toCharArray();

  for (int i = 0; i < cLine.length; i++) {    
    c = cLine[i];    
    if (( c == '\n') || (c == '\r') ) {
      if ( lIdx > 0 ) {                        // Line is complete. Then execute!
        outputLine[lIdx] = '\0';          // Terminate string
        line = String.valueOf(outputLine);        
        processGcode(line);
      } else {
        // Empty or comment line. Skip block.
      }
      lineIsComment = false;
      lineSemiColon = false;
    } else {
      if ( (lineIsComment) || (lineSemiColon) ) {   // Throw away all comment characters
        if ( c == ')' )  lineIsComment = false;     // End of comment. Resume line.
      } else {
        if ( c <= ' ' ) {                           // Throw away whitepace and control characters
        } else if ( c == '/' ) {                    // Block delete not supported. Ignore character.
        } else if ( c == '(' ) {                    // Enable comments flag and ignore all characters until ')' or EOL.
          lineIsComment = true;
        } else if ( c == ';' ) {
          lineSemiColon = true;
        } else {
          outputLine[lIdx++] = c;
        }
      }
    }
  }
}

public void processGcode(String line) {
  String[] sCommand;
  String[] sX, sY, sZ;
  int command;

  switch(line.charAt(0)) {
  case'G':
    StringBuilder sbg = new StringBuilder();
    sbg.append(line);
    sbg.deleteCharAt(0);
    line = sbg.toString();
    sCommand = match(line, "^[0-9]*");      
    command = int(sCommand[0]);  
    switch(command) {
    case 0:
    case 1:    
      sbg.delete(0, sCommand[0].length());
      line = sbg.toString();      
      if (line.charAt(0) == 'X') {    //assume that X is before Y
        sbg.deleteCharAt(0);
        line = sbg.toString();
        sX = match(line, "(^-[0-9]*\\.[0-9]*)|(^-[0-9]*)|(^[0-9]*\\.[0-9]*)|(^[0-9]*)"); 
        if (absolute == false) {
          xPos = xPos + float(sX[0]);
        } else {
          xPos = float(sX[0]);
        }
        sbg.delete(0, sX[0].length());
        line = sbg.toString();
      }
      if (line.charAt(0) == 'Y') {
        sbg.deleteCharAt(0);
        line = sbg.toString();
        sY = match(line, "(^-[0-9]*\\.[0-9]*)|(^-[0-9]*)|(^[0-9]*\\.[0-9]*)|(^[0-9]*)");
        if (absolute == false) {
          yPos = yPos + float(sY[0]);
        } else {
          yPos = float(sY[0]);
        }
      }      
      break;
    case 90:
      if (absolute == false) {
        f.setCaptionLabel("Abs");
        absolute = true;
      }
      break;
    case 91:
      if (absolute == true) {
        f.setCaptionLabel("Rel");
        absolute = false;
      }
      break;
    }
    break;
  case'M':
    StringBuilder sbm = new StringBuilder();
    sbm.append(line);
    sbm.deleteCharAt(0);
    line = sbm.toString();
    sCommand = match(line, "^[0-9]*");      
    command = int(sCommand[0]);  
    switch(command) {
    case 300:
      sbm.delete(0, sCommand[0].length());
      line = sbm.toString();
      if (line.charAt(0) == 'S') {   
        sbm.deleteCharAt(0);
        line = sbm.toString();
        sZ = match(line, "^[0-9]*");      
        if (float(sZ[0]) == 30) {
          zPos = 0;
        } else if (float(sZ[0]) == 50) {
          zPos = 1;
        }
      }
      break;
    case'U':
    case'D':
    }
  }
}

void gcodeSelect (File selection) {
  if (selection == null) {
  } else {    
    path = splitTokens(selection.getAbsolutePath(), "\\");
    text(selection.getAbsolutePath(), 500, 465);
    gcode = loadStrings(selection.getAbsolutePath());
    if (gcode == null) return;
  }
}
