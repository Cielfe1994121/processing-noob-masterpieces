//NeonBackgrounds

void drawMaterialsBackground() {
  background(0);
  float t = millis() * 0.002;
  noStroke();
  for (int i = 0; i < 100; i++) {
    float x = width * noise(i * 0.1, t);
    float y = height * noise(i * 0.2, t + 100);
    float r = 8 + 4 * sin(t + i);
    fill(lerpColor(color(255, 0, 180), color(0, 255, 200), sin(t + i * 0.1) * 0.5 + 0.5), 150);
    ellipse(x, y, r, r);
  }

  stroke(255, 0, 255, 40);
  strokeWeight(1);
  for (int i = 0; i < height; i += 40) {
    float offset = 30 * sin(t + i * 0.05);
    line(0, i + offset, width, i - offset);
  }
}

void drawRestoreModeBackground() {
  colorMode(HSB, 360, 100, 100, 100);
  float t = millis() * 0.001;
  hueValue = (hueValue + 0.2 + sin(t * 0.5) * 0.5) % 360;
  volumeLevel = restorePlayer != null && restorePlayer.isPlaying() ? restorePlayer.mix.level() : 0;
  float brightness = map(volumeLevel, 0, 0.5, 10, 40);
  background(hueValue, 80, brightness);

  noFill();
  stroke(0, 0, 100, 30);
  strokeWeight(1);
  for (int i = 0; i < 20; i++) {
    float x = width * noise(t + i * 0.1);
    float y = height * noise(t + i * 0.2 + 100);
    float r = 30 + 20 * sin(t + i);
    ellipse(x, y, r, r);
  }

  stroke(0, 0, 100, 50);
  for (int i = 0; i < width; i += 40) {
    float offset = 20 * sin(t + i * 0.01);
    line(i, 0, i + offset, height);
  }
  colorMode(RGB, 255);
}




void drawCreateModeBackground() {
  background(0);
  float t = millis() * 0.002;
  float centerX = width / 2;
  float centerY = height / 2 + 100;

  // Determine volume level
  float volume = 0;
  if (isMainPlaybackActive && blockPlayer2D != null && blockPlayer2D.isPlaying()) {
    volume = blockPlayer2D.mix.level();
  }

  // Draw flashy pulsing rings
  if (volume > 0.01) {
    for (int i = 0; i < 3; i++) {
      float baseRadius = 60 + i * 30;
      float pulse = sin(t * 2 + i) * 10 + volume * 150;
      stroke(lerpColor(color(255, 0, 180), color(0, 255, 200), sin(t + i) * 0.5 + 0.5), 180);
      strokeWeight(2 + i);
      noFill();
      ellipse(centerX, centerY, baseRadius + pulse, baseRadius + pulse);
    }

    // Glowing center orb
    noStroke();
    fill(255, 255, 0, 200);
    ellipse(centerX, centerY, 30 + volume * 75, 30 + volume * 75);
  } else {
    // Static center orb before playback
    noStroke();
    fill(100, 100, 255, 100);
    ellipse(centerX, centerY, 40, 40);
  }
}



void drawStartScreenBackground() {
  background(0);
  float t = millis() * 0.001;

  // Animated gradient
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    stroke(lerpColor(color(0, 0, 50), color(0, 255, 255), inter));
    line(0, y, width, y);
  }
// Floating bubbles
noStroke(); // 輪郭線を消す
for (int i = 0; i < 20; i++) {
  float x = width * noise(t + i * 0.1);
  float y = height * noise(t + i * 0.2 + 100);
  float size = 15 + 10 * sin(t + i); // サイズがゆっくり変わる
  
  // ▼ 変更点：色を背景に合わせたシアン系の半透明に
  fill(100, 255, 255, 90); 
  
  // ▼ 変更点：三角形の描画(beginShape)の代わりに円(ellipse)を描画
  ellipse(x, y, size, size);
}
  // Glowing rings
  noFill();
  stroke(100, 255, 255, 80);
  strokeWeight(2);
  for (int i = 0; i < 10; i++) {
    float x = width * noise(t + i * 0.3 + 200);
    float y = height * noise(t + i * 0.4 + 300);
    float r = 30 + 20 * sin(t + i);
    ellipse(x, y, r, r);
  }
}

// --- ▼ここから追加▼ ---

ArrayList<Spark> sparks = new ArrayList<Spark>();
float lastSparkTime = 0;

// ゲームプレイ中の背景
// --- ▼ここから修正▼ ---

ArrayList<FlowParticle> flowParticles = new ArrayList<FlowParticle>();

// ゲームプレイ中の背景
void drawRestoreGameBackground() {
  colorMode(RGB, 255);
  background(15, 0, 30); // 暗い紫がかった青の背景

  float t = millis() * 0.0005; // 時間経過の速さを調整

  // 背景のグリッド（オプション画面より少し細かく、色を調整）
  stroke(50, 0, 150, 40); // 深い紫のグリッド
  strokeWeight(1);
  for (int i = 0; i < height; i += 25) {
    float offset = 5 * sin(t * 1.5 + i * 0.03); // 細かい波
    line(0, i + offset, width, i - offset);
  }
  for (int i = 0; i < width; i += 25) {
    float offset = 5 * cos(t * 1.2 + i * 0.03); // 細かい波
    line(i + offset, 0, i - offset, height);
  }

  // 流れる光のパーティクル
  if (frameCount % 3 == 0) { // 3フレームに1回パーティクルを生成
    flowParticles.add(new FlowParticle());
  }

  for (int i = flowParticles.size() - 1; i >= 0; i--) {
    FlowParticle p = flowParticles.get(i);
    p.update();
    p.draw();
    if (p.isDead()) {
      flowParticles.remove(i);
    }
  }

  // 画面端のネオンボーダー
  colorMode(HSB, 360, 100, 100, 100);
  noFill();
  strokeWeight(5);
 // stroke(borderHue, 90, 90, 150); // カラフルで明るいネオン
  rect(0, 0, width, height, 10); // 角丸のボーダー
  colorMode(RGB, 255); // RGBモードに戻す
}

// 流れる光のパーティクルクラス
class FlowParticle {
  PVector pos;
  PVector vel;
  float lifespan;
  float size;
  color c;

  FlowParticle() {
    pos = new PVector(random(width), random(height));
    vel = PVector.random2D().mult(random(0.5, 1.5)); // 速度を調整
    lifespan = random(150, 250); // 持続時間を調整
    size = random(3, 8); // サイズを調整
    c = lerpColor(color(0, 255, 255), color(255, 0, 255), random(1)); // シアンとマゼンタの間で色を決定
  }

  void update() {
    pos.add(vel);
    lifespan -= 1.5; // 少しゆっくり消える
    // 画面外に出たら反対側から出現する
    if (pos.x < 0) pos.x = width;
    if (pos.x > width) pos.x = 0;
    if (pos.y < 0) pos.y = height;
    if (pos.y > height) pos.y = 0;
  }

  void draw() {
    noStroke();
    // 光彩
    fill(red(c), green(c), blue(c), lifespan * 0.7);
    ellipse(pos.x, pos.y, size * 2, size * 2);
    // 本体
    fill(red(c), green(c), blue(c), lifespan);
    ellipse(pos.x, pos.y, size, size);
  }

  boolean isDead() {
    return lifespan < 0;
  }
}

// --- ▲ここまで修正▲ ---

// Spark クラスと Bubble クラスはそのまま利用するので、削除しないでください。
// もし以前のSparkクラスのコードがまだ残っている場合は、この修正で不要になるので削除しても構いません。
// 新しいdrawRestoreGameBackground()はSparkクラスを使用しません。


// 火花クラス
class Spark {
  PVector pos;
  PVector vel;
  float lifespan;
  color c;

  Spark(float x, float y) {
    pos = new PVector(x, y);
    vel = PVector.random2D().mult(random(1, 3));
    lifespan = 255;
    c = lerpColor(color(0, 255, 255), color(255, 0, 255), random(1));
  }

  void update() {
    pos.add(vel);
    lifespan -= 4;
  }

  void draw() {
    noStroke();
    fill(red(c), green(c), blue(c), lifespan);
    ellipse(pos.x, pos.y, 5, 5);
  }

  boolean isDead() {
    return lifespan < 0;
  }
}

ArrayList<Bubble> bubbles = new ArrayList<Bubble>();

// ゲームクリア画面の背景
void drawGameClearBackground() {
  colorMode(RGB, 255);
  background(10, 5, 20); // 暗い紫色

  // 定期的に新しいバブルを追加
  if (frameCount % 2 == 0) {
    bubbles.add(new Bubble());
  }

  // バブルの描画と更新
  for (int i = bubbles.size() - 1; i >= 0; i--) {
    Bubble b = bubbles.get(i);
    b.update();
    b.draw();
    if (b.isOffscreen()) {
      bubbles.remove(i);
    }
  }
}

// 泡クラス
class Bubble {
  float x, y;
  float size;
  float speed;
  color c;
  float xOffset;

  Bubble() {
    x = random(width);
    y = height + 20;
    size = random(5, 25);
    speed = random(1, 3);
    xOffset = random(1000);
    c = lerpColor(color(255, 220, 0), color(0, 255, 255), random(1));
  }

  void update() {
    y -= speed;
    x += sin(y * 0.05 + xOffset) * 0.8;
  }

  void draw() {
    float alpha = map(y, height, 0, 200, 0);
    noStroke();
    // 光彩
    fill(red(c), green(c), blue(c), alpha * 0.5);
    ellipse(x, y, size * 1.5, size * 1.5);
    // 本体
    fill(red(c), green(c), blue(c), alpha);
    ellipse(x, y, size, size);
  }

  boolean isOffscreen() {
    return y < -20;
  }
}

// --- ▲ここまで追加▲ ---
