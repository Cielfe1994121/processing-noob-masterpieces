//2025/6/4

float x = 0;
float y = 0;
float t = 0;
//float t = 950;
float g = 0;
int h = 0;
void setup()
{
 size(600,600);
 background(165,74,0);
 }

void draw()
{ 
  if( t <= 100)
  {
    t = t + 0.1;
   x = random(601);
   y = random(601);
   fill(0,0,255);
   noStroke();
   circle(x,y,1);
  }
 if( t <= 500 && t >= 20)
  {
   x = random(601);
   y = random(601);
   circle(x,y,3);
   t ++;
  }
  if( t <= 1000 && t >= 250)
  {
   x = random(601);
   y = random(601);
   circle(x,y,5);
  }
 if( t < 1000 &&  800 <= t)
  {
    background(165-g,74+g,0);
    x = random(401);
    y = random(401);
  //  circle(x,y,5);
    g = g + 0.5;
  //  fill(165-g,74+g,0);
  }
  if( 1000 <= t && t < 1200)
  {
    fill(42,175,48);
    ellipse(width/2,height/2,100, 100 - h);
  }
  if( 1200 <= t && t <= 1750)
  {
     background(165-g,74+g,0);
     fill(255);
     rect(0, 0, width,   h);
     rect(0, height, width, -h);
     noStroke();
   // fill(165-g,74+g*1.5,0);
    // ellipse( width/2 ,height/2 - h, 100 + h, 100 + h);
     fill(165,74,0);
     ellipse(width/2,height/2,100, 100 - h);
     rect(width/2 - 50, height/2, 100, -h);
     fill(165-g,74+g*2,0);
     ellipse( width/2 ,height/2 - h, 100 + h/2, 100 + h/2);
     if(h <= 150)
     {
     h ++;
     }
  }
  t ++;
  println(t);
}
   
   
