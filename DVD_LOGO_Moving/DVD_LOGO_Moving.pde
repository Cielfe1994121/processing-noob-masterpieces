//2025/7/9

PImage DVD;
int x = 100;
int y = 100;
int vx = 2;
int vy = 2;

int r = 255;
int g = 255;
int b = 255;

void setup() 
{
  size(800, 500);
  DVD = loadImage("DVD.png");
  frameRate(60); // フレームレートの指定（任意）
}

void draw() {
  background(0);

  // 位置を先に更新
  x += vx;
  y += vy;

  // 壁に当たったかチェック
  boolean bounced = false;
  if (x <= 0 || x >= width - DVD.width) {
    vx = -vx;
    bounced = true;
  }
  if (y <= 0 || y >= height - DVD.height) {
    vy = -vy;
    bounced = true;
  }

  if (bounced) {
    changeColor();
  }

  // 色を設定して描画
  tint(r, g, b);
  image(DVD, x, y);
  noTint();
}

void changeColor() {
  r = int(random(50, 256));
  g = int(random(50, 256));
  b = int(random(50, 256));
}
