import oscP5.*;
import netP5.*;

import static javax.swing.JOptionPane.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

final int ROWS=16;
final int COLUMNS=16;

int rows,columns;
int currentRow;
int margin;

int idleColor;
int activeColor;
int idleRowColor;
int activeRowColor;

MatrixButton [][] matrix;

void setup()
{

  size(500,500);

  final String hostAddress = showInputDialog("Server IP address","localhost");

  // start oscP5 and listen for incoming messages at port
  oscP5 = new OscP5(this,7778);
  
  // use the following IP/port combination to send messages
  myRemoteLocation = new NetAddress(hostAddress,7777);

  rows=ROWS; // default
  columns=COLUMNS; // default
  matrix = new MatrixButton[rows][columns];
  for(int row=0; row<rows; row++){
    for(int col=0; col<columns; col++){
      matrix[row][col] = new MatrixButton();
    }
  }

  margin=3; // space around each 'button'

  float rectWidth=(width-(columns+1)*margin)/columns;
  float rectHeight=(height-(rows+1)*margin)/rows;

  frameRate(30);

  currentRow=15;
  idleColor=color(100,100,175);
  activeColor=color(200,225,225);
  // selected row
  idleRowColor=color(0,200,100);
  activeRowColor=color(200,225,225);

  for(int row=0; row<rows; row++){
    for(int col=0; col<columns; col++){
      matrix[row][col].setGeometry(col*rectWidth+(col+1)*margin,
          row*rectHeight+(row+1)*margin,rectWidth,rectHeight);
      if(row==currentRow)
        matrix[row][col].setColors(idleRowColor,activeRowColor);
      else
        matrix[row][col].setColors(idleColor,activeColor);
    } // for
  } // for

  // send registration message to server
  OscMessage myMessage = new OscMessage("/register");
  myMessage.add(0);
  oscP5.send(myMessage,myRemoteLocation); 
} // setup


void draw()
{
  background(0);
  for(int row=0; row<rows; row++){
    for(int col=0; col<columns; col++){
      matrix[row][col].draw();
    } // for
  } // for
} // draw()


/*
 * The function oscEvent is triggered when a message comes in
 */
void oscEvent(OscMessage theOscMessage)
{
int row,col;
boolean status;

  String msgType = theOscMessage.addrPattern();

  if(msgType.equals("/box/status")) {
    row = theOscMessage.get(0).intValue();
    col = theOscMessage.get(1).intValue();
    status = theOscMessage.get(2).intValue() != 0 ? true : false;
    if(row >= rows || col >= columns) return; // ignore illegal row/col
    if(row < 0 || col < 0) return; // ignore illegal row/col
    matrix[row][col].setStatus(status);
  } // if

  if(msgType.equals("/box/columns")) {
    columns = theOscMessage.get(0).intValue();
    if(columns>COLUMNS) columns=COLUMNS; // upper bound
    if(columns<2) columns=2; // lower bound
    windowResized(width,height);
  } // if

} // oscEvent()



void keyPressed()
{
boolean carry,status;

  if(key == CODED) {
    switch(keyCode) {
      case DOWN:
	for(int col=0; col<columns; col++)
	  matrix[currentRow][col].setColors(idleColor,activeColor);
	currentRow = (currentRow+1)%rows;
	for(int col=0; col<columns; col++)
	  matrix[currentRow][col].setColors(idleRowColor,activeRowColor);
      return;
      case UP:
	for(int col=0; col<columns; col++)
	  matrix[currentRow][col].setColors(idleColor,activeColor);
	if(currentRow==0) currentRow=rows-1;
	else currentRow = (currentRow-1)%rows;
	for(int col=0; col<columns; col++)
	  matrix[currentRow][col].setColors(idleRowColor,activeRowColor);
      return;
      case LEFT:
	carry=matrix[currentRow][0].getStatus();
	for(int col=0; col<columns-1; col++)
	  matrix[currentRow][col].setStatus(matrix[currentRow][col+1].getStatus());
	matrix[currentRow][columns-1].setStatus(carry);
      break;
      case RIGHT:
	carry=matrix[currentRow][columns-1].getStatus();
	for(int col=columns-1; col>0; col--)
	  matrix[currentRow][col].setStatus(matrix[currentRow][col-1].getStatus());
	matrix[currentRow][0].setStatus(carry);
      break;
    } // switch
  } // if
  else{
    switch(key) {
      case ' ':
	for(int col=0; col<columns; col++)
	  matrix[currentRow][col].setStatus(false);
      break;
      case 'i':
	for(int col=0; col<columns; col++)
	  matrix[currentRow][col].setStatus(!matrix[currentRow][col].getStatus());
      break;
      case 'r': // (re-)register
	OscMessage myMessage = new OscMessage("/register");
	myMessage.add(0);
	oscP5.send(myMessage,myRemoteLocation); 
      break;
    } // switch
  } // else

  for(int col=0; col<columns; col++){
    status=matrix[currentRow][col].getStatus();
    OscMessage myMessage = new OscMessage("/box/setstatus");
    myMessage.add(currentRow);
    myMessage.add(col);
    myMessage.add(status?1:0);
    oscP5.send(myMessage,myRemoteLocation);
  } // for
} // keyPressed()


void mousePressed()
{
boolean newstatus;

  for(int row=0; row<rows; row++){
    for(int col=0; col<columns; col++){
      if(matrix[row][col].pointerIsIn(mouseX,mouseY)){
        newstatus=matrix[row][col].toggleStatus();
	OscMessage myMessage = new OscMessage("/box/setstatus");
	myMessage.add(row);
	myMessage.add(col);
	myMessage.add(newstatus?1:0);
	oscP5.send(myMessage,myRemoteLocation); 
	return;
      } // if
    } // for
  } // for
} // mousePressed()


void windowResized(int w, int h)
{
float rectWidth=(w-(columns+1)*margin)/columns;
float rectHeight=(h-(rows+1)*margin)/rows;

  for(int row=0; row<rows; row++){
    for(int col=0; col<columns; col++){
      matrix[row][col].setGeometry(col*rectWidth+(col+1)*margin,
          row*rectHeight+(row+1)*margin,rectWidth,rectHeight);
    } // for
  } // for
} // windowResized()