//UI
void setupUIFont() {
  jpFont = createFont("SansSerif", 32);
  textFont(jpFont);
}

void drawTabs() {
  setupUIFont();
  fill(0, 0, 30); // Dark background
  rect(0, 0, width, 40);
  textAlign(CENTER, CENTER);
  textSize(14);

  for (int i = 1; i <= 3; i++) {
    int x = width / 5 * i;
    boolean isActive = (i == 1 && currentMode == Mode.START) ||
                       (i == 2 && currentMode == Mode.MATERIALS) ||
                       (i == 3 && currentMode == Mode.RESTORE);
    fill(isActive ? color(0, 255, 255) : color(100));
    text(i == 1 ? "スタート" :
         i == 2 ? "素材置き場" :
                  "復元モード", x, 20);
  }

  // ポーズボタン（右上）
  float px = width - 35;
  float py = 15;
  float h = 20;
  float gap = 5;
  float r = 18;

  strokeWeight(4);
  stroke(255, 255, 0, 150);
  noFill();
  circle(px, py + h/2, r * 2);

  strokeWeight(2);
  stroke(255, 255, 0);
  circle(px, py + h/2, r * 2);

  strokeWeight(5);
  stroke(255, 255, 0, 150);
  line(px - gap, py, px - gap, py + h);
  line(px + gap, py, px + gap, py + h);

  strokeWeight(3);
  stroke(255, 255, 0);
  line(px - gap, py, px - gap, py + h);
  line(px + gap, py, px + gap, py + h);
}

void handleTabClick() {
  if (mouseY < 40) {
    if (mouseX < width / 5 * 2) {
      currentMode = Mode.START;
    } else if (mouseX < width / 5 * 3) {
      currentMode = Mode.MATERIALS;
    } else if (mouseX < width / 5 * 4) {
      currentMode = Mode.RESTORE;
    } else {
      isPaused = !isPaused;
    }
  }
}
