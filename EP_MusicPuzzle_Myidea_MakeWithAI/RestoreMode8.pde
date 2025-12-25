//RestoreMode
boolean showRestoreLabels = true;
boolean startSoundPlayed = false;
// --- 正誤判定用変数とサウンド ---
AudioPlayer seikaiSound;
AudioPlayer suitekiSound;
AudioPlayer fuseikaiSound;
ArrayList<Effect> effects = new ArrayList<Effect>();
boolean evaluatingSequence = false;
int evaluationIndex = 0;
int evaluationStartTime = 0;
float finalAccuracy = 0;

// --- エフェクトクラス ---
class Effect {
  int x, y;
  int startTime;
  boolean correct;
  Effect(int x, int y, boolean correct) {
    this.x = x;
    this.y = y;
    this.correct = correct;
    this.startTime = millis();
  }
  void draw() {
    int elapsed = millis() - startTime;
    if (elapsed > 600) return;
    pushMatrix();
    translate(x, y);
    if (correct) {
      // カラーモードをHSBに変更
      colorMode(HSB, 360, 100, 100, 100); 

      // 時間と共に変化する色相 (虹色の循環)
      float baseHue = (millis() * 0.2f) % 360; 

      // 1. 中心から広がる鮮やかな光の輪 (複数重ねて厚みを出す)
      for (int i = 0; i < 3; i++) {
        float delayFactor = i * 0.05; // わずかな時間差で重なりを表現
        float currentElapsed = max(0, elapsed - 600 * delayFactor); // 遅延を考慮
        float progress = currentElapsed / (600 * (1 - delayFactor)); // 進行度

        if (progress > 0 && progress <= 1) {
          float radius = map(progress, 0, 1, 0, 150); // 広がる最大半径を大きく
          float alpha = map(progress, 0, 1, 100, 0); // 透明度が徐々に減衰

          // 虹色に光る
          float hue = (baseHue + i * 60) % 360; // それぞれの円で少し色相をずらす
          stroke(hue, 95, 100, alpha); // 鮮やかな色
          strokeWeight(4 + (2 - i) * 2); // 中心に近いほど太く

          noFill();
          ellipse(0, 0, radius, radius);
        }
      }

      // 2. さらに広がる薄い光のグロー
      float glowRadius = map(elapsed, 0, 600, 50, 250); // より大きく広がる
      float glowAlpha = map(elapsed, 0, 600, 50, 0); // 薄い透明度

      stroke((baseHue + 180) % 360, 80, 90, glowAlpha); // 補色に近い色で深みを出す
      strokeWeight(1);
      noFill();
      ellipse(0, 0, glowRadius, glowRadius);
      
      // カラーモードをデフォルトのRGBに戻す
      colorMode(RGB, 255); 

    } else {
      int alpha = 128 + int(100 * sin(elapsed * 0.05));
      fill(255, 50, 50, alpha);
      noStroke();
      rect(-restoreBlockWidth/2, -40, restoreBlockWidth, 81, 11);
      stroke(255, 0, 0, alpha/2);
      strokeWeight(5);
      rect(-restoreBlockWidth/2, -40, restoreBlockWidth, 81, 11);
    }
    popMatrix();
  }
}

// --- drawRestoreBlocks にエフェクト描画と完成度表示を追加 ---
ArrayList<PVector> dragTrail = new ArrayList<PVector>();
int bounceStartTime = 0;
boolean isBouncing = false;
float bounceScale = 1.0;

int bounceBlockA = -1;
int bounceBlockB = -1;

void drawRippleTrail() {
  noFill();
  stroke(100, 200, 255);
  strokeWeight(2);
  for (int i = 0; i < dragTrail.size(); i++) {
    PVector p = dragTrail.get(i);
    float age = millis() - p.z;
    if (age < 400) {
      float alpha = map(age, 0, 400, 255, 0);
      float radius = map(age, 0, 400, 0, 40);
      stroke(100, 200, 255, alpha);
      ellipse(p.x, p.y, radius, radius);
    }
  }
}
void drawDragTrail() {
  noStroke();
  for (int i = 0; i < dragTrail.size(); i++) {
    PVector p = dragTrail.get(i);
    float age = millis() - p.z;
    if (age < 300) {
      float alpha = map(age, 0, 300, 255, 0);
      fill(100, 200, 255, alpha);
      ellipse(p.x, p.y, 20, 20);
    }
  }
}

void updateBounce() {
  if (isBouncing) {
    int elapsed = millis() - bounceStartTime;
    if (elapsed < 300) {
      float t = elapsed / 300.0;
      bounceScale = 1.0 + 0.2 * sin(TWO_PI * t);
    } else {
      bounceScale = 1.0;
      isBouncing = false;
    }
  }
}

//RestoreMode
import ddf.minim.*;
AudioPlayer restoreBGM;
AudioPlayer countdownSound;
AudioPlayer startSound;
int lastCountdownSecond = -1;

String[] difficulties = {"Easy", "Normal", "Hard", "Hell"};
int selectedDifficultyIndex = 1; // Default to Normal

String selectedMaterialFile = "";
int restoreBlockCount = 10;
int restoreBlockDurationMillis;
int restoreBlockWidth;
int[] restoreBlockOrder;
int[] correctOrder;
int restoreDraggingBlock = -1;

boolean restoreSequencePlaying = false;
int restoreSequenceIndex = 0;
int restoreSequenceStartTime = 0;
int restoreBlockStartTime = 0;

AudioPlayer restorePreviewPlayer;
boolean isPreviewPlaying = false;
int previewStartTime = 0;
int previewBlockIndex = -1;

AudioPlayer completedPlayer;
boolean showResultScreen = false;
int finalScore = 0;
int highScore = 0;
int gameStartTime = 0;
int timeLimitMillis = 60000;
ArrayList<Integer> partialSequence = new ArrayList<Integer>();
int selectedTimeOption = 60;

boolean restoreGameStarted = false;
//int countdownStartTime = 0;
//boolean isCountdownActive = false;

void setupRestoreModeWithFile(String filename) {
  if (restorePlayer != null) restorePlayer.close();
  restorePlayer = minim.loadFile(filename, 2048);
  if (restorePlayer == null) {
    println("ファイル読み込み失敗: " + filename);
    return;
  }

  restoreBlockDurationMillis = restorePlayer.length() / restoreBlockCount;
  restoreBlockWidth = width / restoreBlockCount;

  restoreBlockOrder = new int[restoreBlockCount];
  correctOrder = new int[restoreBlockCount];
  color[] neonColors = { color(0, 255, 255), color(255, 0, 255), color(180, 0, 255), color(0, 255, 200), color(128, 255, 0), color(255, 128, 0) };
  for (int i = 0; i < restoreBlockCount; i++) {
    correctOrder[i] = i;
    restoreBlockOrder[i] = i;
  }

  for (int i = restoreBlockCount - 1; i > 0; i--) {
    int j = int(random(i + 1));
    int temp = restoreBlockOrder[i];
    restoreBlockOrder[i] = restoreBlockOrder[j];
    restoreBlockOrder[j] = temp;
  }
}

float calculateReproductionRate() {
  int correct = 0;
  for (int i = 0; i < restoreBlockCount; i++) {
    if (restoreBlockOrder[i] == correctOrder[i]) {
      correct++;
    }
  }
  return (float)correct / restoreBlockCount * 100.0;
}

// 変更点: ポーズボタンのデザインを修正
void drawPauseButton() {
  float x = width - 35;
  float y = 15; // 少し上に移動
  float h = 20;
  float gap = 5;
  float circleRadius = 18;

  // 丸の光彩
  strokeWeight(4);
  stroke(255, 255, 0, 150); // ネオンイエローの光
  noFill();
  circle(x, y + h/2, circleRadius * 2);

  // 丸の本体
  strokeWeight(2);
  stroke(255, 255, 0); // ネオンイエロー
  noFill();
  circle(x, y + h/2, circleRadius * 2);

  // 縦線の光彩
  strokeWeight(5);
  stroke(255, 255, 0, 150);
  line(x - gap, y, x - gap, y + h);
  line(x + gap, y, x + gap, y + h);

  // 縦線の本体
  strokeWeight(3);
  stroke(255, 255, 0);
  line(x - gap, y, x - gap, y + h);
  line(x + gap, y, x + gap, y + h);
}

void drawRestoreMode() {
  if (isPaused) {
    drawPauseOverlay();
    return;
  }

  if (!restoreGameStarted && !isCountdownActive) {
    if (restoreBGM == null) {
      restoreBGM = minim.loadFile("Suityuu3.mp3", 2048);
      restoreBGM.loop();
      updateBgmVolume();
    }
  } else {
    if (restoreBGM != null) {
      restoreBGM.close();
      restoreBGM = null;
    }
  }

  drawRestoreModeBackground();
  drawPauseButton(); 

  if (isCountdownActive) {
    drawCountdown();
    return;
  }

  if (!restoreGameStarted) {
    drawRestoreOptions();
    return;
  }

  updateBounce();
  if (showResultScreen) {
    drawResultScreen();
    return;
  }

   drawTitleTexts();

  if (!restoreGameStarted) {
    for (int i = 0; i < materials.size(); i++) {
      AudioMaterial m = materials.get(i);
      int bx = 100 + i * 160;
      int by = 100;
      boolean isSelected = m.filePath.equals(selectedMaterialFile);
      color buttonColor = isSelected ? color(255, 200, 0) : color(0, 200, 255);
      color glowColor = isSelected ? color(255, 220, 50, 150) : color(50, 200, 255, 150);
      drawNeonButton(m.displayName, bx, by, 140, 30, buttonColor, glowColor, 15);
    }
  }

  if (!selectedMaterialFile.equals("")) {
    drawRestoreBlocks();
    drawRippleTrail();
    drawRestoreSequence();
    drawGameStats();
    if (restoreDraggingBlock != -1) {
      int dragX = mouseX;
      int dragIndex = restoreDraggingBlock;
      for (int i = 0; i < restoreBlockCount; i++) {
        if (i != dragIndex) {
          int x = i * restoreBlockWidth;
          if (mouseX > x && mouseX < x + restoreBlockWidth) {
            int temp = restoreBlockOrder[dragIndex];
            restoreBlockOrder[dragIndex] = restoreBlockOrder[i];
            restoreBlockOrder[i] = temp;
            bounceBlockA = dragIndex;
            bounceBlockB = i;
            if (suitekiSound != null) suitekiSound.close();
            suitekiSound = minim.loadFile("Suiteki1.mp3", 2048);
            suitekiSound.play();
            bounceStartTime = millis();
            isBouncing = true;
            restoreDraggingBlock = i;
            bounceBlockA = i;
            bounceBlockB = -1;
            if (suitekiSound != null) suitekiSound.close();
            suitekiSound = minim.loadFile("Suiteki1.mp3", 2048);
            suitekiSound.play();
            bounceStartTime = millis();
            isBouncing = true;
            break;
          }
        }
      }
      dragTrail.add(new PVector(mouseX, mouseY, millis()));
      if (dragTrail.size() > 30) dragTrail.remove(0);
    }
  }
}

void drawNeonButton(String label, float x, float y, float w, float h, color neonColor, color fillColor, float cornerRadius) {
  // ボタンの枠（光彩）
  noFill();
  stroke(neonColor, 150);
  strokeWeight(5);
  rect(x, y, w, h, cornerRadius);

  // ボタンの本体
  fill(fillColor);
  noStroke();
  rect(x, y, w, h, cornerRadius);

  // テキスト描画
  textAlign(CENTER, CENTER);
 
  // --- ▼ここから変更▼ ---
  // テキストがボタン幅に収まるようにサイズを動的に調整
  float currentTextSize = 16; //基準の文字サイズ
  textSize(currentTextSize);
  // 文字の幅がボタンの幅（左右に少し余白を持たせる）を超える場合は、サイズを小さくする
  while (textWidth(label) > w - 10 && currentTextSize > 8) {
    currentTextSize--;
    textSize(currentTextSize);
  }
  // ボタン内の文字はアウトラインなしでくっきり表示
  fill(neonColor); // ネオンカラーで塗る
  text(label, x + w / 2, y + h / 2);
  textSize(16);
}

void drawGameStats() {
  int elapsed = millis() - gameStartTime;
  int remaining = max(0, timeLimitMillis - elapsed);
  float rate = calculateReproductionRate();
  float multiplier = selectedTimeOption == 30 ? 3.0 : selectedTimeOption == 90 ? 0.5 : 1.0;
  int score = int(rate * (remaining / 1000.0) * multiplier * (showRestoreLabels ? 1 : 5));
  finalScore = score;

  textSize(28); // テキストサイズを少し大きくして見やすくする

// --- ▼ テキストカラーを白に統一 ▼ ---
  color infoGlow = color(180); // グレーの光彩
  color infoText = color(255); // 白色のテキスト本体

  // 右側に情報を表示
  textAlign(RIGHT, TOP);
  String remainingText = "残り時間: " + (remaining / 1000) + "秒";
  String scoreText = "スコア: " + score;

  // 残り時間の描画 (光彩)
  fill(infoGlow);
  for (int dx = -1; dx <= 1; dx++) text(remainingText, width - 20 + dx, 60);
  // 残り時間の描画 (本体)
  fill(infoText);
  text(remainingText, width - 20, 60);

  // スコアの描画 (光彩)
  fill(infoGlow);
  for (int dx = -1; dx <= 1; dx++) text(scoreText, width - 20 + dx, 95);
  // スコアの描画 (本体)
  fill(infoText);
  text(scoreText, width - 20, 95);

  // 左側に情報を表示
  textAlign(LEFT, TOP);
  String difficultyText = "難易度: " + difficulties[selectedDifficultyIndex];
  String timeLimitText = "制限時間: " + selectedTimeOption + "秒";

  // 難易度の描画 (光彩)
  fill(infoGlow);
  for (int dx = -1; dx <= 1; dx++) text(difficultyText, 20 + dx, 60);
  // 難易度の描画 (本体)
  fill(infoText);
  text(difficultyText, 20, 60);

  // 制限時間の描画 (光彩)
  fill(infoGlow);
  for (int dx = -1; dx <= 1; dx++) text(timeLimitText, 20 + dx, 95);
  // 制限時間の描画 (本体)
  fill(infoText);
  text(timeLimitText, 20, 95);
}

void drawResultScreen() {
  if (finalScore > highScore) highScore = finalScore;
  drawGameClearBackground();  // 背景は黒のまま
  textAlign(CENTER, CENTER);

  // --- 「ゲームクリア！」をネオン表示 ---
  textSize(64);
  String clearText = "GAME CLEAR";
  float tx = width / 2;
  float ty = height / 2 - 130;
  float t = millis() * 0.003; // アニメーション速度

  noStroke();
  // 1. 外側のぼやけたグロー（アニメーション付き）
  fill(255, 200, 0, 40 + 20 * sin(t)); // オレンジがかったイエローの光
  for(int i = 0; i < 5; i++) { // 複数回描画してぼかしを表現
    text(clearText, tx + random(-4, 4), ty + random(-4, 4));
  }

  // 2. 中間のグロー（はっきりした光）
  fill(255, 220, 50, 150); // 明るいイエローの光
  text(clearText, tx + 1, ty + 1);
  text(clearText, tx - 1, ty - 1);

  // 3. テキスト本体（深みのある色）
  fill(80, 60, 0);
  text(clearText, tx, ty);
  // --- スコアをネオン表示 ---
 textSize(28);

  String scoreText = "SCORE: " + finalScore;

  color cyan = color(0, 255, 255);

  color cyanGlow = color(0, 200, 200);

  // 光彩

  for (int dx = -1; dx <= 1; dx++) text(scoreText, width/2 + dx, height/2 - 60 + dx);

  // 本体

  fill(cyan);

  text(scoreText, width/2, height/2 - 60);



  String highScoreText = "H! SCORE: " + highScore;

  color honorColor = color(255, 255, 0);

  color honorGlow = color(0, 255, 255);

  for (int dx = -1; dx <= 1; dx++) text(highScoreText, width/2 + dx, height/2 - 20 + dx);

  fill(honorColor);

  text(highScoreText, width/2, height/2 - 20);



  // --- 3つのボタンを横並びに配置 ---
  textSize(16);
  int btnW = 150; // ボタンの幅
  int btnH = 40;  // ボタンの高さ
  int gap = 30;   // ボタン間の隙間
  int totalW = btnW * 3 + gap * 2;
  int startX = width/2 - totalW/2;
  int btnY = height/2 + 50;

  // 1. リトライボタン (イエロー)
  drawNeonButton("リトライ", startX, btnY, btnW, btnH, color(255, 255, 0), color(50, 50, 0), 10);
  // 2. 曲選択へボタン (マゼンタ)
  drawNeonButton("曲選択へ", startX + btnW + gap, btnY, btnW, btnH, color(255, 0, 255), color(50, 0, 50), 10);
  // 3. タイトルへボタン (シアン)
  drawNeonButton("タイトルへ", startX + (btnW + gap) * 2, btnY, btnW, btnH, color(0, 200, 255), color(0, 40, 80), 10);
}

void drawRestoreBlocks() {
  int y = height / 2 - 40;
  for (int i = 0; i < restoreBlockCount; i++) {
    int x = i * restoreBlockWidth;
    int blockIndex = restoreBlockOrder[i];

    boolean isActiveBlock = restoreSequencePlaying && restoreSequenceIndex == i;
    stroke(isActiveBlock ? color(255, 100, 100) : color(0, 255, 255));
    strokeWeight(isActiveBlock ? 3 : 1);

    fill(lerpColor(color(0, 255, 255, 50), color(0), 0.5));
    pushMatrix();
    translate(x + restoreBlockWidth/2, y + 40);
    float s = (i == bounceBlockA || i == bounceBlockB) ? bounceScale : 1.0;
    scale(s);
    rect(-restoreBlockWidth/2, -40, restoreBlockWidth, 80, 12);
    popMatrix();

     if (showRestoreLabels) {
        fill(0, 255, 255);
        // 「Block 」を削除し、blockIndexに1を足して表示
        text(blockIndex + 1, x + restoreBlockWidth / 2, y + 20);
     }

    fill(isPreviewPlaying && previewBlockIndex == blockIndex ? color(255, 100, 100) : color(0, 255, 255));
    ellipse(x + restoreBlockWidth / 2, y + 60, 15, 15);

    if (isPreviewPlaying && previewBlockIndex == blockIndex && restorePreviewPlayer != null && restorePreviewPlayer.isPlaying()) {
      float previewProgress = float(millis() - previewStartTime) / restoreBlockDurationMillis;
      previewProgress = constrain(previewProgress, 0, 1);
      stroke(color(0, 255, 255));
      strokeWeight(3);
      line(x, y + 85, x + restoreBlockWidth * previewProgress, y + 85);
    }

    if (isActiveBlock && restorePlayer != null && restorePlayer.isPlaying()) {
      float blockProgress = float(millis() - restoreBlockStartTime) / restoreBlockDurationMillis;
      blockProgress = constrain(blockProgress, 0, 1);
      stroke(255, 100, 100);
      strokeWeight(3);
      line(x, y + 85, x + restoreBlockWidth * blockProgress, y + 85);
    }
  }

 // 再生ボタンの色を、より鮮やかなネオングリーンに変更
  color playButtonColor = restoreSequencePlaying ? color(255, 100, 100) : color(0, 255, 128); // 停止中はネオングリーン
  // ボタンの塗りつぶし色を暗くして、枠のネオン色を際立たせる
  color playFillColor = restoreSequencePlaying ? color(80, 20, 20) : color(0, 50, 30);
  
  // drawNeonButtonに渡す色を変更
 // drawNeonButton("再生", width/2 - 40, height - 40, 80, 30, playButtonColor, playFillColor, 10);
   drawNeonButton("再生", width/2 - 75, height - 80, 150, 50, playButtonColor, playFillColor, 15); // 変更後
  for (int i = effects.size() - 1; i >= 0; i--) {
    effects.get(i).draw();
    if (millis() - effects.get(i).startTime > 600) {
      effects.remove(i);
    }
  }

  if (evaluatingSequence) {
    textAlign(CENTER, CENTER);
    textSize(24);
    String accuracyText = "完成度 " + nf(finalAccuracy, 0, 1) + "%";
    color accColor = color(255, 255, 0);
    color accGlow = color(180, 180, 0); // 光彩を少し暗く
    color accTextColor = color(255, 255, 50); // 本体を明るく
    // 光彩
    fill(accGlow);
    for (int dx = -1; dx <= 1; dx++) text(accuracyText, width/2 + dx, 175); // dx, dyを調整
    // 本体
    fill(accTextColor);
    text(accuracyText, width/2, 175);
  }
}

void handleRestoreModeClick() {
  if (handlePauseClick()) return;

  // --- 結果画面の処理 ---
 if (showResultScreen) {
    // --- ▼判定エリアを新しいボタンレイアウトに合わせる▼ ---
    int btnW = 150;
    int btnH = 40;
    int gap = 30;
    int totalW = btnW * 3 + gap * 2;
    int startX = width/2 - totalW/2;
    int btnY = height/2 + 50;

    // 1. リトライボタンの判定
    if (mouseX > startX && mouseX < startX + btnW && mouseY > btnY && mouseY < btnY + btnH) {
      showResultScreen = false;
      setupRestoreModeWithFile(selectedMaterialFile);
      if (completedPlayer != null) completedPlayer.close();
      completedPlayer = null;
      countdownStartTime = millis();
      isCountdownActive = true;
      return;
    }
    
    // 2. 曲選択へボタンの判定
    float selectBtnX = startX + btnW + gap;
    if (mouseX > selectBtnX && mouseX < selectBtnX + btnW && mouseY > btnY && mouseY < btnY + btnH) {
      resetGame();
      return;
    }
    
    // 3. タイトルへボタンの判定 (新しく追加)
    float titleBtnX = startX + (btnW + gap) * 2;
    if (mouseX > titleBtnX && mouseX < titleBtnX + btnW && mouseY > btnY && mouseY < btnY + btnH) {
      resetGame();
      currentMode = Mode.START; // STARTモード(タイトル画面)に戻る
      return;
    }
 }


  // --- ゲーム開始前のオプション画面の処理 ---
  if (!restoreGameStarted) {
    // 難易度選択
    for (int i = 0; i < 3; i++) {
      int totalWidth = (110 * 3) + (20 * 2);
      int startX = width/2 - totalWidth/2;
      int bx = startX + i * 130;
      int by = 260;
      if (mouseX > bx && mouseX < bx + 110 && mouseY > by && mouseY < by + 40) {
        selectedDifficultyIndex = i;
        if (i == 0) restoreBlockCount = 5;
        else if (i == 1) restoreBlockCount = 10;
        else if (i == 2) restoreBlockCount = 20;
        if (!selectedMaterialFile.equals("")) {
          setupRestoreModeWithFile(selectedMaterialFile);
        }
        return;
      }
    }

    // 制限時間選択
    int[] timeOptions = {30, 60, 90};
    for (int i = 0; i < timeOptions.length; i++) {
      int totalWidth = (110 * 3) + (20 * 2);
      int startX = width/2 - totalWidth/2;
      int bx = startX + i * 130;
      int by = 370;
      if (mouseX > bx && mouseX < bx + 110 && mouseY > by && mouseY < by + 40) {
        selectedTimeOption = timeOptions[i];
        timeLimitMillis = selectedTimeOption * 1000;
        return;
      }
    }

    // ラベル表示切替
    float labelButtonX = width/2 - 100;
    float labelButtonY = 450;
    if (mouseX > labelButtonX && mouseX < labelButtonX + 200 && mouseY > labelButtonY && mouseY < labelButtonY + 40) {
      showRestoreLabels = !showRestoreLabels;
      return;
    }

    // 開始ボタン
    float startButtonX = width/2 - 75;
    float startButtonY = height - 80;
    if (mouseX > startButtonX && mouseX < startButtonX + 150 && mouseY > startButtonY && mouseY < startButtonY + 50 && !selectedMaterialFile.equals("")) {
      countdownStartTime = millis();
      isCountdownActive = true;
      return;
    }

    // 素材選択
    for (int i = 0; i < materials.size(); i++) {
      AudioMaterial m = materials.get(i);
      int bx = 100 + i * 180;
      int by = 150;
      if (mouseX > bx && mouseX < bx + 160 && mouseY > by && mouseY < by + 40) {
        selectedMaterialFile = m.filePath;
        setupRestoreModeWithFile(selectedMaterialFile);
        return;
      }
    }

  // --- ゲーム開始後の処理 ---
  } else {
    // ブロックの操作
    int y = height / 2 - 40;
    for (int i = 0; i < restoreBlockCount; i++) {
      int x = i * restoreBlockWidth;
      int blockIndex = restoreBlockOrder[i];

      // プレビュー再生用の小さい丸をクリック
      if (!restoreSequencePlaying && dist(mouseX, mouseY, x + restoreBlockWidth / 2, y + 60) < 8) {
        if (isPreviewPlaying && previewBlockIndex == blockIndex) {
          stopRestorePreview();
        } else {
          stopRestorePreview();
          playRestorePreview(blockIndex);
        }
        return;
      }

      // ブロック本体をクリックしてドラッグ開始
      if (mouseY > y && mouseY < y + 80 && mouseX > x && mouseX < x + restoreBlockWidth) {
        // --- ▼以前の動作（音とバウンス）をここに追加▼ ---
        bounceBlockA = i;
        bounceBlockB = -1;
        isBouncing = true;
        bounceStartTime = millis();

        if (suitekiSound != null) suitekiSound.close();
        suitekiSound = minim.loadFile("Suiteki1.mp3", 2048);
        suitekiSound.play();
        // --- ▲ここまで▲ ---

        restoreDraggingBlock = i;
        dragTrail.add(new PVector(x + restoreBlockWidth/2, y + 40, millis()));
        return;
      }
    }

    // 再生ボタンのクリック
    //if (mouseX > width/2 - 40 && mouseX < width/2 + 40 && mouseY > height - 40 && mouseY < height - 10) {
       if (mouseX > width/2 - 75 && mouseX < width/2 + 75 && mouseY > height - 80 && mouseY < height - 30) { // 変更後
      if (restoreSequencePlaying) {
        stopRestoreSequence();
      } else {
        stopRestorePreview();
        if (calculateReproductionRate() == 100.0) {
          showResultScreen = true;
          completedPlayer = minim.loadFile(selectedMaterialFile, 2048);
          if (completedPlayer != null) completedPlayer.play();
        } else {
          evaluatingSequence = true;
          evaluationIndex = 0;
          evaluationStartTime = millis();
          finalAccuracy = calculateReproductionRate();
        }
      }
      return;
    }
  }
}

void handleRestoreMouseRelease() {
  if (restoreDraggingBlock != -1) {
    int dropIndex = mouseX / restoreBlockWidth;
    if (dropIndex >= 0 && dropIndex < restoreBlockCount && dropIndex != restoreDraggingBlock) {
      int temp = restoreBlockOrder[restoreDraggingBlock];
      restoreBlockOrder[restoreDraggingBlock] = restoreBlockOrder[dropIndex];
      restoreBlockOrder[dropIndex] = temp;
      bounceBlockA = restoreDraggingBlock;
      bounceBlockB = dropIndex;
      if (suitekiSound != null) suitekiSound.close();
      suitekiSound = minim.loadFile("Suiteki1.mp3", 2048);
      suitekiSound.play();
      bounceStartTime = millis();
      isBouncing = true;
    }
    restoreDraggingBlock = -1;
  }
}

void playRestorePreview(int blockIndex) {
  restorePreviewPlayer = minim.loadFile(selectedMaterialFile, 2048);
  if (restorePreviewPlayer != null) {
    if (blockIndex >= 0) {
      restorePreviewPlayer.cue(blockIndex * restoreBlockDurationMillis);
    }
    restorePreviewPlayer.play();
    isPreviewPlaying = true;
    previewStartTime = millis();
    previewBlockIndex = blockIndex;
  }
}

void stopRestorePreview() {
  if (restorePreviewPlayer != null) {
    restorePreviewPlayer.close();
    restorePreviewPlayer = null;
  }
  isPreviewPlaying = false;
  previewBlockIndex = -1;
}

void playRestoreSequence() {
  if (restoreSequenceIndex >= restoreBlockCount) {
    stopRestoreSequence();
    return;
  }

  int blockIndex = restoreBlockOrder[restoreSequenceIndex];
  if (restorePlayer != null) restorePlayer.close();
  restorePlayer = minim.loadFile(selectedMaterialFile, 2048);
  if (restorePlayer != null) {
    restorePlayer.cue(blockIndex * restoreBlockDurationMillis);
    restorePlayer.play();
    restoreBlockStartTime = millis();
    restoreSequencePlaying = true;
  }
}

void stopRestoreSequence() {
  if (restorePlayer != null) {
    restorePlayer.close();
    restorePlayer = null;
  }
  restoreSequencePlaying = false;
  restoreSequenceIndex = 0;
}

void drawRestoreSequence() {
  if (evaluatingSequence) {
    int interval = 500;
    if (millis() - evaluationStartTime >= interval) {
      evaluationStartTime = millis();
      if (evaluationIndex < restoreBlockCount) {
        int blockIndex = restoreBlockOrder[evaluationIndex];
        int correctIndex = correctOrder[evaluationIndex];
        int x = evaluationIndex * restoreBlockWidth + restoreBlockWidth / 2;
        int y = height / 2;
        boolean isCorrect = (blockIndex == correctIndex);
        effects.add(new Effect(x, y, isCorrect));
        if (isCorrect) {
          if (seikaiSound != null) seikaiSound.close();
          seikaiSound = minim.loadFile("Seikai.mp3", 2048);
          seikaiSound.play();
        } else {
          if (fuseikaiSound != null) fuseikaiSound.close();
          fuseikaiSound = minim.loadFile("Fuseikai.mp3", 2048);
          fuseikaiSound.play();
        }
        evaluationIndex++;
      } else {
        evaluatingSequence = false;
      }
    }
  }

  if (restoreSequencePlaying && restorePlayer != null) {
    int elapsed = millis() - restoreBlockStartTime;
    if (elapsed >= restoreBlockDurationMillis) {
      restoreSequenceIndex++;
      if (partialSequence.size() > 0) {
        playPartialSequence(partialSequence);
      } else {
        playRestoreSequence();
      }
    }
  }

  if (isPreviewPlaying && restorePreviewPlayer != null) {
    int previewElapsed = millis() - previewStartTime;
    if (previewElapsed >= restoreBlockDurationMillis) {
      stopRestorePreview();
    }
  }
}

void simulatePartialPlayback() {
  partialSequence.clear();
  for (int i = 0; i < restoreBlockCount; i++) {
    if (restoreBlockOrder[i] == correctOrder[i]) {
      partialSequence.add(restoreBlockOrder[i]);
    } else {
      break;
    }
  }

  if (partialSequence.size() > 0) {
    restoreSequencePlaying = true;
    restoreSequenceIndex = 0;
    restoreSequenceStartTime = millis();
    playPartialSequence(partialSequence);
  }
}

void playPartialSequence(ArrayList<Integer> indices) {
  partialSequence = indices;
  if (restoreSequenceIndex >= partialSequence.size()) {
    stopRestoreSequence();
    return;
  }

  int blockIndex = partialSequence.get(restoreSequenceIndex);
  if (restorePlayer != null) restorePlayer.close();
  restorePlayer = minim.loadFile(selectedMaterialFile, 2048);
  if (restorePlayer != null) {
    restorePlayer.cue(blockIndex * restoreBlockDurationMillis);
    restorePlayer.play();
    restoreBlockStartTime = millis();
    restoreSequencePlaying = true;
  }
}

//RestoreMode374行目
int countdownStartTime = 0;
boolean isCountdownActive = false;

void drawRestoreOptions() {
  // --- ▼ここから全体を修正▼ ---
  textAlign(CENTER, CENTER);
 // --- ▼ タイトルデザインを修正 ▼ ---
 textSize(60);
  String title = "復元モード:オプション";
  float tx = width / 2;
  float ty = 45;
  float t = millis() * 0.003; // アニメーション速度

  noStroke();
  // 1. 外側のぼやけたグロー（アニメーション付き）
  fill(0, 200, 100, 40 + 20 * sin(t)); // ネオングリーンの光
  for(int i = 0; i < 5; i++) { // 複数回描画してぼかしを表現
    text(title, tx + random(-3, 3), ty + random(-3, 3));
  }

  // 2. 中間のグロー（はっきりした光）
  fill(50, 220, 150, 150);
  text(title, tx + 1, ty + 1);
  text(title, tx - 1, ty - 1);

  // 3. テキスト本体（ネオン管の中心）
  fill(0, 50, 40);
  text(title, tx, ty);
  // --- ▲ ここまで修正 ▲ ---
  // --- 素材選択 ---
  textSize(20); // ラベルのサイズを大きく
  String materialLabel = "素材を選択してください";
  color labelColor = color(255);
  color labelGlow = color(180); // 光彩を少し暗く
  color labelTextColor = color(255); // 本体を明るく
  // 光彩
  fill(labelGlow);
  for (int dx = -1; dx <= 1; dx++) text(materialLabel, width/2 + dx, 120); // dx, dyを調整
  // 本体
  fill(labelTextColor);
  text(materialLabel, width/2, 120);
  
  for (int i = 0; i < materials.size(); i++) {
    AudioMaterial m = materials.get(i);
    // ボタンの位置とサイズを調整
    int bx = 100 + i * 180; // ボタン間の距離を広げる
    int by = 150;
    boolean isSelected = m.filePath.equals(selectedMaterialFile);
    color buttonColor = isSelected ? color(255, 200, 0) : color(0, 200, 255);
    color fillColor = isSelected ? color(80, 60, 0) : color(0, 40, 50);
    drawNeonButton(m.displayName, bx, by, 160, 40, buttonColor, fillColor, 15); // ボタンを大きく
  }

  // --- 難易度選択 ---
  textSize(20); // ラベルのサイズを大きく
  String diffLabel = "難易度";
  // 光彩 (色は上で定義済み)
  fill(labelGlow);
  for (int dx = -1; dx <= 1; dx++) text(diffLabel, width/2 + dx, 230); // dx, dyを調整
  // 本体 (色は上で定義済み)
  fill(labelTextColor);
  text(diffLabel, width/2, 230);
  
  String[] difficulties = {"Easy", "Normal", "Hard"};
  for (int i = 0; i < difficulties.length; i++) {
    // ボタンの位置とサイズを調整
    int totalWidth = (110 * 3) + (20 * 2); // ボタン3つと隙間の合計幅
    int startX = width/2 - totalWidth/2;
    int bx = startX + i * 130; // ボタン幅 + 隙間
    int by = 260;
    boolean isSelected = i == selectedDifficultyIndex;
    color buttonColor = isSelected ? color(255, 0, 255) : color(180, 0, 255);
    color fillColor = isSelected ? color(80, 0, 80) : color(30, 0, 50);
    drawNeonButton(difficulties[i], bx, by, 110, 40, buttonColor, fillColor, 10); // ボタンを大きく
  }

  // --- 制限時間選択 ---
  textSize(20); // ラベルのサイズを大きく
  String timeLabel = "制限時間";
  // 光彩 (色は上で定義済み)
  fill(labelGlow);
  for (int dx = -1; dx <= 1; dx++) text(timeLabel, width/2 + dx, 340); // dx, dyを調整
  // 本体 (色は上で定義済み)
  fill(labelTextColor);
  text(timeLabel, width/2, 340);
  
  int[] timeOptions = {30, 60, 90};
  for (int i = 0; i < timeOptions.length; i++) {
    // ボタンの位置とサイズを調整 (難易度選択とレイアウトを合わせる)
    int totalWidth = (110 * 3) + (20 * 2);
    int startX = width/2 - totalWidth/2;
    int bx = startX + i * 130;
    int by = 370;
    boolean isSelected = timeOptions[i] == selectedTimeOption;
    color buttonColor = isSelected ? color(0, 255, 128) : color(0, 200, 100);
    color fillColor = isSelected ? color(0, 80, 60) : color(0, 40, 20);
    drawNeonButton(timeOptions[i] + "秒", bx, by, 110, 40, buttonColor, fillColor, 10); // ボタンを大きく
  }

  // --- ラベル表示切替 ---
  boolean isLabelOn = showRestoreLabels;
  color labelButtonColor = isLabelOn ? color(255, 255, 0) : color(200, 200, 0);
  color labelFillColor = isLabelOn ? color(80, 80, 0) : color(40, 40, 0);
  // ボタンの位置とサイズを調整
  drawNeonButton("ラベル表示: " + (isLabelOn ? "ON" : "OFF"), width/2 - 100, 450, 200, 40, labelButtonColor, labelFillColor, 10);

  // --- 開始ボタン ---
  boolean canStart = !selectedMaterialFile.equals("");
  color startButtonColor = canStart ? color(0, 255, 255) : color(50, 100, 100);
  color startFillColor = canStart ? color(0, 50, 80) : color(10, 20, 20);
  // ボタンの位置とサイズを調整
  drawNeonButton("開始", width/2 - 75, height - 80, 150, 50, startButtonColor, startFillColor, 15);
  // --- ▲ここまで全体を修正▲ ---
}

void drawCountdown() {
  int elapsed = millis() - countdownStartTime;
  int remaining = 3000 - elapsed;

  if (remaining < 0) remaining = 0;

  int displaySecond = (int)ceil(remaining / 1000.0);

  if (displaySecond != lastCountdownSecond && displaySecond > 0) {
    if (countdownSound != null) countdownSound.close();
    countdownSound = minim.loadFile("Suiteki1.mp3", 2048);
    countdownSound.play();
    lastCountdownSecond = displaySecond;
  }

  if (remaining <= 0) {
    if (!startSoundPlayed) {
      if (startSound != null) startSound.close();
      startSound = minim.loadFile("Suiteki2.mp3", 2048);
      startSound.play();
      startSoundPlayed = true; // 再生したことを記録
    }
    isCountdownActive = false;
    restoreGameStarted = true;
    gameStartTime = millis();
    lastCountdownSecond = -1;
    return;
  }

  background(0);
  textAlign(CENTER, CENTER);
  
  // --- ▼ここから変更▼ ---
  textSize(96); // 数字を大きくして迫力を出す

  // 表示する数字によって色を決定
  color textColor = color(255);
  color glowColor = color(200); // 光彩の基本色を少し暗く

  switch(displaySecond) {
    case 3: // 3はネオングリーン
      textColor = color(50, 255, 128); // 本体を明るく
      glowColor = color(0, 180, 100); // 光彩を少し暗く
      break;
    case 2: // 2はネオンイエロー
      textColor = color(255, 255, 50); // 本体を明るく
      glowColor = color(180, 180, 0); // 光彩を少し暗く
      break;
    case 1: // 1はネオンレッド
      textColor = color(255, 100, 100); // 本体を明るく
      glowColor = color(180, 0, 0); // 光彩を少し暗く
      break;
  }

  String numStr = str(displaySecond);
  float x = width/2;
  float y = height/2;

  // 光彩を描画 (オフセットを小さく)
  fill(glowColor);
  for (int dx = -1; dx <= 1; dx++) { // dx, dyの範囲を狭める
    for (int dy = -1; dy <= 1; dy++) {
      if (dx != 0 || dy != 0) {
        text(numStr, x + dx, y + dy);
      }
    }
  }

  // テキスト本体を描画 (中心に)
  fill(textColor);
  text(numStr, x, y);
  // --- ▲ここまで変更▲ ---
}

float hueValue = 200;
float volumeLevel = 0;

boolean isPaused = false;

void drawPauseOverlay() {
  fill(0, 0, 0, 200);
  rect(0, 0, width, height);
  textAlign(CENTER, CENTER);
  textSize(24);
  
 textSize(48); // 文字を大きく
  String pauseText = "ポーズ中";
  float tx = width / 2;
  float ty = height / 2 - 140; // Y座標を調整
  float t = millis() * 0.003; // アニメーション速度

  noStroke();
  // 1. 外側のぼやけたグロー（アニメーション付き）
  fill(0, 180, 180, 40 + 20 * sin(t)); // シアン系の光
  for(int i = 0; i < 5; i++) { // 複数回描画してぼかしを表現
    text(pauseText, tx + random(-3, 3), ty + random(-3, 3));
  }

  // 2. 中間のグロー（はっきりした光）
  fill(50, 255, 255, 150); // 明るいシアンの光
  text(pauseText, tx + 1, ty + 1);
  text(pauseText, tx - 1, ty - 1);

  // 3. テキスト本体
  fill(0, 50, 80);
  text(pauseText, tx, ty);
   textSize(24);
  // --- ▼ ボタンの構成を6つに変更 ▼ ---
  String[] buttons = {"再開", "リスタート", "曲選択", "素材置き場", "創造モード", "タイトルへ戻る"};
  for (int i = 0; i < buttons.length; i++) {
    color buttonColor;
    color fillColor = color(10, 20, 40);
    switch (i) {
      case 0: buttonColor = color(0, 255, 128); break;   // 再開
      case 1: buttonColor = color(255, 255, 0); break;   // リスタート
      case 2: buttonColor = color(255, 0, 255); break;   // 曲選択
      case 3: buttonColor = color(255, 128, 0); break;   // 素材置き場
      case 4: buttonColor = color(0, 255, 128); break;   // 創造モードへ (New)
      case 5: buttonColor = color(0, 200, 255); break;   // タイトルへ戻る
      default: buttonColor = color(200); break;
    }
    // Y座標のレイアウトを調整 (開始位置を上げ、間隔を狭める)
    drawNeonButton(buttons[i], width/2 - 80, height/2 - 90 + i * 42, 160, 35, buttonColor, fillColor, 10);
  }
}

boolean handlePauseClick() {
  if (!isPaused) return false;

  // --- ▼ ボタンのY座標と数を新しいレイアウトに合わせる ▼ ---
  for (int i = 0; i < 6; i++) {
    int bx = width/2 - 80;
    int by = height/2 - 90 + i * 42; // レイアウトを合わせる
    if (mouseX > bx && mouseX < bx + 160 && mouseY > by && mouseY < by + 35) {
      if (i == 0) { // 「再開」ボタン
        isPaused = false;
      } else if (i == 1) { // 「リスタート」ボタン
        resetGame();
        setupRestoreModeWithFile(selectedMaterialFile);
        countdownStartTime = millis();
        isCountdownActive = true;
      } else if (i == 2) { // 「曲選択」ボタン (旧オプションへ)
        resetGame();
      } else if (i == 3) { // 「素材置き場」ボタン
        resetGame();
        currentMode = Mode.MATERIALS;
      } else if (i == 4) { // 「創造モードへ」ボタン (New)
        resetGame();
        currentMode = Mode.CREATE;
      } else if (i == 5) { // 「タイトルへ戻る」ボタン
        resetGame();
        currentMode = Mode.START;
      }
      return true;
    }
  }
  return true;
}
// ゲームをリセットしてオプション画面に戻すための関数
void resetGame() {
  // 再生中のサウンドをすべて停止
  if (restorePlayer != null) restorePlayer.close();
  if (restorePreviewPlayer != null) restorePreviewPlayer.close();
  if (completedPlayer != null) completedPlayer.close();
  if (restoreBGM != null) restoreBGM.close();
  if (startSound != null) startSound.close(); // <<< この行を追加
  restoreBGM = null;

  // ゲームの状態をリセット
  restoreGameStarted = false;
  isPaused = false;
  showResultScreen = false;
  isCountdownActive = false;
  startSoundPlayed = false; // <<< この行を追加
  effects.clear();
  dragTrail.clear();
}

void drawTitleTexts() {
  textAlign(CENTER, CENTER);

  // --- ▼ タイトルデザインをネオングリーンに統一 ▼ ---
textSize(60);
  String title = "復元モード";
  float tx = width / 2;
  float ty = 45;
  float t = millis() * 0.003; // アニメーション速度

  noStroke();
  // 1. 外側のぼやけたグロー（アニメーション付き）
  fill(0, 200, 100, 40 + 20 * sin(t)); // ネオングリーンの光
  for(int i = 0; i < 5; i++) { // 複数回描画してぼかしを表現
    text(title, tx + random(-3, 3), ty + random(-3, 3));
  }

  // 2. 中間のグロー（はっきりした光）
  fill(50, 220, 150, 150);
  text(title, tx + 1, ty + 1);
  text(title, tx - 1, ty - 1);

  // 3. テキスト本体（ネオン管の中心）
  fill(0, 50, 40);
  text(title, tx, ty);

  // === サブタイトルの描画 ===
  textSize(24);
  String subTitle = !restoreGameStarted ? "素材を選択してください" : "曲を完成させよう";
  float subTitleX = width / 2;
  float subTitleY = !restoreGameStarted ? 95 : height / 2 - 200;

  color titleGlow = color(100, 100, 100);
  color titleText = color(255);
  
  fill(titleGlow);
  for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
      if (dx != 0 || dy != 0) {
        text(subTitle, subTitleX + dx, subTitleY + dy);
      }
    }
  }
  fill(titleText);
  text(subTitle, subTitleX, subTitleY);
}
