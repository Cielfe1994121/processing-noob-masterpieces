//hw_ServerClientApp.pde
//宿題① サーバ・クライアントで通信を行う何らかのアプリを作成するプログラム。○×ゲームを作成。
//2025/11/26

import processing.net.*;
Server myServer = new Server( this, 9876 );
int turn = 0;

int[][] units = new int[3][3];
int ux, uy;

void setup() {
  size(300, 300);
  textSize(48);
  textAlign(CENTER,CENTER);
  for (int x = 0; x < 3; x++)
  {
    for (int y = 0; y < 3; y++)
    {
      if (x == 0)
      {
        units[x][y] = x + y + 3 ;
      } else if (x == 1)
      {
        units[x][y] = x + y + 1 + 3 ;
      } else if (x == 2)
      {
        units[x][y] = x + y + 2 + 3 ;
      }
    }
  }
}

void mousePressed() {
  if (turn%2 == 0)
  {
    int ux = mouseX/100;
    int uy = mouseY/100;

    setUnit(1, ux, uy);

    turn++;
    myServer.write(ux + "," + uy + "," + turn);
  }
  for (int x = 0; x < 3; x++)
  {
    for (int y = 0; y < 3; y++)
    {
      println(units[x][y]);
    }
  }
}

void draw() {
  Client nextClient = myServer.available();
  if ( nextClient != null ) {
    String msgData = nextClient.readString();
    String data[] = split(msgData, ',');
    ux = int(data[0]);
    uy = int(data[1]);
    turn = int(data[2]);
    setUnit(2, ux, uy);
  }

  marubatu();
  win(0, 0);
}
