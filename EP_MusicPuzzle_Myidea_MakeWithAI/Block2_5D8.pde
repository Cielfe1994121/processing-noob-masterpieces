//Block2_5D

class Block2_5D {
  String filePath;
  int startMillis;
  int durationMillis;
  float x, y;
  float depth;
  float baseWidth = 140;
  float baseHeight = 30;
  String label;

  AudioPlayer previewPlayer;
  boolean isPreviewPlaying = false;
  int previewStartTime = 0;
  
  boolean wasPaused = false;
  boolean isActive = false;

  Block2_5D(String filePath, int startMillis, int durationMillis, float x, float y, float depth, String label) {
    this.filePath = filePath;
    this.startMillis = startMillis;
    this.durationMillis = durationMillis;
    this.x = x;
    this.y = y;
    this.depth = constrain(depth, 0, 1);
    this.label = label;
  }

  void draw() {
    float scale = map(1 - depth, 0, 1, 0.5, 1.0);
    float w = baseWidth * scale;
    float h = baseHeight * scale;
    int alpha = int(map(1 - depth, 0, 1, 100, 255));
    float depthPx = map(depth, 0, 1, 4, 12);

    color neonPink = color(255, 0, 180);
    color emeraldGreen = color(0, 255, 200);
    color neonPurple = color(180, 0, 255);
    color neonBlue = color(0, 255, 255);

    // 影
    fill(0, alpha * 0.15);
    noStroke();
    beginShape();
    vertex(x - w/2 + 4, y + h/2 + 4);
    vertex(x + w/2 + 4, y + h/2 + 4);
    vertex(x + w/2 + 4, y + h/2 + depthPx + 4);
    vertex(x - w/2 + 4, y + h/2 + depthPx + 4);
    endShape(CLOSE);

    // 正面
    noStroke();
    for (int i = 0; i < int(h); i++) {
      float inter = map(i, 0, h, 0, 1);
      fill(lerpColor(neonPink, emeraldGreen, inter), alpha);
      rect(x - w/2, y - h/2 + i, w, 1, 8);
    }

    // 側面（右）
    fill(neonPurple, alpha * 0.8);
    beginShape();
    vertex(x + w/2, y - h/2);
    vertex(x + w/2 + depthPx, y - h/2 - depthPx);
    vertex(x + w/2 + depthPx, y + h/2 - depthPx);
    vertex(x + w/2, y + h/2);
    endShape(CLOSE);

    // 上面
    fill(neonPink, alpha * 0.6);
    beginShape();
    vertex(x - w/2, y - h/2);
    vertex(x + w/2, y - h/2);
    vertex(x + w/2 + depthPx, y - h/2 - depthPx);
    vertex(x - w/2 + depthPx, y - h/2 - depthPx);
    endShape(CLOSE);

    // ラベル
    textAlign(LEFT, CENTER);
    // textFont(jpFont); // 必要に応じて有効化してください
    textSize(12);
    String displayLabel = label;
    while (textWidth(displayLabel) > w - 25 && displayLabel.length() > 0) {
      displayLabel = displayLabel.substring(0, displayLabel.length() - 1);
    }
    fill(neonBlue, alpha);
    text(displayLabel, x - w/2 + 5, y);

    // 再生ボタン
    fill(isPreviewPlaying ? color(255, 100, 100, alpha) : neonBlue);
    ellipse(x + w/2 - 10, y, 15, 15);

    if (isPreviewPlaying && millis() - previewStartTime > durationMillis) {
      stopPreview();
    }

    if (isPreviewPlaying) {
      float progressRatio = float(millis() - previewStartTime) / durationMillis;
      drawProgressBar(constrain(progressRatio, 0, 1));
    }
    
     // ▼▼▼ ここから下のコードを draw() メソッドの最後に追加 ▼▼▼
 // ▼▼▼ この if 文のブロックを丸ごと差し替えてください ▼▼▼
  
  // もしこのブロックがアクティブなら、全側面にハイライトを描画する
  if (isActive) {
    // 変数を再計算（w, h, depthPxがこのスコープで必要なため）
    float scale2 = map(1 - depth, 0, 1, 0.5, 1.0);
    float w2 = baseWidth * scale;
    float h2 = baseHeight * scale;
    float depthPx2 = map(depth, 0, 1, 4, 12);

    // ハイライトの設定
    noFill();
    stroke(255, 255, 0, 220); // 少し不透明度を上げて見やすく
    strokeWeight(3); // 太さを少し調整

    // --- 前面の四角形の輪郭 ---
    line(x - w2/2, y - h2/2, x + w2/2, y - h2/2); // 上辺
    line(x + w2/2, y - h2/2, x + w/2, y + h2/2); // 右辺
    line(x + w2/2, y + h2/2, x - w/2, y + h2/2); // 下辺
    line(x - w2/2, y + h2/2, x - w/2, y - h2/2); // 左辺

    // --- 奥の面の輪郭（見える部分のみ） ---
    line(x - w2/2 + depthPx, y - h/2 - depthPx, x + w2/2 + depthPx, y - h2/2 - depthPx); // 上辺
    line(x + w2/2 + depthPx, y - h/2 - depthPx, x + w2/2 + depthPx, y + h2/2 - depthPx); // 右辺

    // --- 前面と奥を結ぶ輪郭（見える部分のみ） ---
    line(x - w2/2, y - h2/2, x - w/2 + depthPx2, y - h2/2 - depthPx2);
    line(x + w2/2, y - h2/2, x + w/2 + depthPx2, y - h2/2 - depthPx2);
    line(x + w2/2, y + h2/2, x + w/2 + depthPx2, y + h2/2 - depthPx2);
  }
  // ▲▲▲ ここまで差し替え ▲▲▲


  }

  void drawProgressBar(float progressRatio) {
    float scale = map(1 - depth, 0, 1, 0.5, 1.0);
    float w = baseWidth * scale;
    float h = baseHeight * scale;
    float barWidth = w * progressRatio;
    stroke(255, 255, 0);
    strokeWeight(2);
    line(x - w/2, y + h/2 + 2, x - w/2 + barWidth, y + h/2 + 2);
  }

  boolean isMouseOver() {
    float scale = map(1 - depth, 0, 1, 0.5, 1.0);
    float w = baseWidth * scale;
    float h = baseHeight * scale;
    return mouseX > x - w/2 && mouseX < x + w/2 &&
           mouseY > y - h/2 && mouseY < y + h/2;
  }

  boolean isPlayButtonClicked() {
    float scale = map(1 - depth, 0, 1, 0.5, 1.0);
    float w = baseWidth * scale;
    return dist(mouseX, mouseY, x + w/2 - 10, y) < 8;
  }

  void playPreview() {
    stopPreview();
    previewPlayer = minim.loadFile(filePath);
    previewPlayer.cue(startMillis);
    previewPlayer.play();
    isPreviewPlaying = true;
    previewStartTime = millis();
    wasPaused = false;
    
    // ▼▼▼ 修正 ▼▼▼
    // このブロックのプレイヤーをビジュアライザーの対象に設定
    visualizerPlayer = this.previewPlayer;
    fft = new FFT(visualizerPlayer.bufferSize(), visualizerPlayer.sampleRate());
  }

  void stopPreview() {
    stopPreview(false);
  }

  void stopPreview(boolean pause) {
    if (previewPlayer != null) {
      if (pause) {
        previewPlayer.pause();
        wasPaused = true;
      } else {
        previewPlayer.close();
        previewPlayer = null;
        wasPaused = false;
      }
    }
    isPreviewPlaying = false;
    
    // ▼▼▼ 修正 ▼▼▼
    // プレビュー停止/一時停止時にビジュアライザーの対象を解除
    visualizerPlayer = null;
  }

  void adjustDepth(float delta) {
    depth = constrain(depth + delta, 0, 1);
  }
}
