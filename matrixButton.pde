
public class MatrixButton
{
float x,y,width,height;
boolean status=false;
int idleColor=color(50);
int activeColor=color(255);

  MatrixButton() { } // constructor

  void setGeometry(float x,float y,float width,float height)
  {
    this.x=x;
    this.y=y;
    this.width=width;
    this.height=height;
  }

  void setColors(int idleColor,int activeColor)
  {
    this.idleColor=idleColor;
    this.activeColor=activeColor;
  }

  void setStatus(boolean status)
  {
    this.status=status;
  }

  boolean toggleStatus()
  {
    status=!status;
    return status;
  }


  boolean getStatus()
  {
    return status;
  }


  boolean pointerIsIn(float x,float y)
  {
    if(x>=this.x && x<=this.x+width &&
       y>=this.y && y<=this.y+height) return true;
    else return false;
  }


  void draw()
  {
    if(status) fill(activeColor);
    else fill(idleColor);
    rect(x,y,width,height);
  }

} // matrixButton{}

