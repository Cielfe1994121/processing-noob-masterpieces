void marubatu() {
  background(255);
  for (int x=0; x<3; x++) {
    for (int y=0; y<3; y++) {
      stroke(0);
      fill(255);
      rect(x*100, y*100, 100, 100);
      if (units[x][y] == 1) {
        noFill();
        ellipse(x*100+50, y*100+50, 80, 80);
      } else if (units[x][y] == 2) {
        fill(0);
        line(x*100+25, y*100+25, x*100+75, y*100+75);
        line(x*100+25, y*100+75, x*100+75, y*100+25);
      }
    }
  }
}

void setUnit(int id, int x, int y) {
  units[x][y] = id;
}

void win(int x, int y)
{
  if ((units[x][y] == units[x+1][y+1] && units[x][y] == units[x+2][y+2] )
    ||( units[x+2][y] == units[x+1][y+1] && units[x+2][y] == units[x][y+2])
    ||( units[x][y] == units[x+1][y] && units[x][y] == units[x+2][y])
    ||( units[x][y+1] == units[x+1][y+1] && units[x][y+1] == units[x+2][y+1])
    ||( units[x][y+2] == units[x+1][y+2] && units[x][y+2] == units[x+2][y+2])
    ||( units[x][y] == units[x][y+1] && units[x][y] == units[x][y+2])
    ||( units[x+1][y] == units[x+1][y+1] && units[x+1][y] == units[x+1][y+2])
    ||( units[x+2][y] == units[x+1][y+1] && units[x+2][y] == units[x+2][y+2]))
  {
    if (turn%2 == 1)
    {
      fill(0);
      background(255);
      text("Maru Win", width/2, height/2);
    } else
    {
      fill(0);
      background(255);
      text("Maru Lose", width/2, height/2);
    }
  }
}
