// CreateMode
// 必要なライブラリのインポート
import ddf.minim.analysis.*;
import java.util.HashSet;

// =======================================================================
// グローバル変数
// =======================================================================
// --- 再生状態管理 ---
// ... (既存の変数) ...
long fullSequenceDuration = 0; // シーケンス全体の合計時間を保持
long completedStepsDuration = 0; // 再生が完了したステップの合計時間
// --- ブロック管理 ---
ArrayList<Block2_5D> blockLibrary2D = new ArrayList<Block2_5D>();
ArrayList<Block2_5D> timelineBlocks2D = new ArrayList<Block2_5D>();

// --- ドラッグ操作 ---
Block2_5D draggingBlock2D = null;
boolean draggingFromLibrary2D = false;
float dragOffsetX2D = 0;
float dragOffsetY2D = 0;

// --- 再生状態管理 ---
boolean blockPlaying2D = false;
String currentMaterialName = "";
int blockStartTime = 0;
int totalSequenceDuration = 0;

boolean isMainPlaybackActive = false;
ArrayList<ArrayList<Block2_5D>> playbackSequence = new ArrayList<>();
ArrayList<AudioPlayer> activeStepPlayers = new ArrayList<>();
int currentPlaybackStep = 0;

import ddf.minim.AudioPlayer;
AudioPlayer grabSound;
AudioPlayer releaseSound;
// --- ▲▲▲ ここまで追加 ▲▲▲ ---


// ... (既存のコード) ...


// =======================================================================
// setup関数 (もしなければこの関数をまるごと追加してください)
// =======================================================================


// --- オーディオビジュアライザー ---
FFT fft;
AudioPlayer visualizerPlayer = null;


// =======================================================================
// 主要な関数 (モードのメイン処理)
// =======================================================================

/**
 * CreateModeのメイン描画関数
 */
/**
 * CreateModeのメイン描画関数
 */
void drawCreateMode() {
  if (isPaused) {
    drawPauseOverlay2();
    return;
  }
  drawCreateModeBackground();
  drawPauseButton2();

textAlign(CENTER, CENTER);
  textFont(createFont("SansSerif", 32));
  textSize(52);
  
  String title = "創造モード（2.5D）";
  float tx = width/2;
  float ty = 40;
  float t = millis() * 0.003; // アニメーション速度

  noStroke();
  // 1. 外側のぼやけたグロー（アニメーション付き）
  fill(200, 0, 200, 40 + 20 * sin(t)); // ネオンマゼンタの光
  for(int i = 0; i < 5; i++) { // 複数回描画してぼかしを表現
    text(title, tx + random(-4, 4), ty + random(-4, 4));
  }

  // 2. 中間のグロー（はっきりした光）
  fill(255, 100, 255, 150); // やや明るいマゼンタ
  text(title, tx + 1, ty + 1);
  text(title, tx - 1, ty - 1);

  // 3. テキスト本体（ネオン管の中心）
  fill(50, 0, 50); // 元の深みのある本体色
  text(title, tx, ty);
  // --- 素材選択UI ---
  textSize(21);
  color subTitleGlow = color(180);
  color subTitleText = color(255);
  
  // 光彩
  fill(subTitleGlow);
  for (int dx = -1; dx <= 1; dx++) text("素材を選んでブロック化", width/2 + dx, 110);
  
  // 本体
  fill(subTitleText);
  text("素材を選んでブロック化", width/2, 110);
  for (int i = 0; i < materials.size(); i++) {
    AudioMaterial m = materials.get(i);
    float bx = 100 + i * 160;
    float by = 130;
    drawCreateModeMaterialButton(m.displayName, bx, by, 140, 30);
  }

  // --- タイムラインエリアの描画 ---
  stroke(255, 255, 0);
  strokeWeight(3);
  fill(0, 0, 0, 60);
  rect(50, height/2, width - 100, height/2 - 100);

  // --- オーディオビジュアライザーの描画 ---
  drawVisualizer();

  // --- ブロックライブラリの描画 ---
  for (Block2_5D b : blockLibrary2D) {
    b.draw();
  }
  
  // --- ▼▼▼ ここから復活・修正 ▼▼▼ ---
  // --- タイムライン上のブロック接続ラインの描画 ---
  // 先にブロックをX座標でソートして、正しく隣同士で線が引かれるようにする
  ArrayList<Block2_5D> sortedBlocks = new ArrayList<>(timelineBlocks2D);
  sortedBlocks.sort((a, b) -> Float.compare(a.x, b.x));

  for (int i = 1; i < sortedBlocks.size(); i++) {
    Block2_5D b1 = sortedBlocks.get(i - 1);
    Block2_5D b2 = sortedBlocks.get(i);
    // X座標が近いブロック同士を線で結ぶ
    if (abs(b2.x - b1.x) <= 160) {
      float midX = (b1.x + b2.x) / 2;
      float midY = (b1.y + b2.y) / 2;
      strokeWeight(3);
      stroke(lerpColor(color(255, 0, 200), color(0, 255, 200), sin(millis() * 0.005)));
      line(b1.x, b1.y, b2.x, b2.y);
      noStroke();
      fill(lerpColor(color(255, 0, 200), color(100, 100, 255), sin(millis() * 0.005)), 100);
      ellipse(midX, midY, 20, 20);
    }
  }
  // --- ▲▲▲ ここまで復活・修正 ▲▲▲ ---

 // ▼▼▼ ここから下のブロックを丸ごと差し替え ▼▼▼

  // --- 全てのブロックのアクティブ状態を更新 ---
  if (isMainPlaybackActive && currentPlaybackStep < playbackSequence.size()) {
    // 現在のステップで再生されるべきブロックのリストを取得
    ArrayList<Block2_5D> activeBlocksInStep = playbackSequence.get(currentPlaybackStep);
    for (Block2_5D b : timelineBlocks2D) {
      // 再生リストに含まれていればアクティブ、そうでなければ非アクティブに設定
      if (activeBlocksInStep.contains(b)) {
        b.isActive = true;
      } else {
        b.isActive = false;
      }
    }
  } else {
    // 再生中でなければ、全てのブロックを非アクティブに
    for (Block2_5D b : timelineBlocks2D) {
      b.isActive = false;
    }
  }

  // --- タイムライン上のブロックと再生エフェクトの描画 ---
  for (Block2_5D b : timelineBlocks2D) {
    b.draw(); // ブロック自身がisActive状態に応じてハイライトを描画する

    // アクティブなブロックのプログレスバーは引き続きここで描画
    if (b.isActive) {
      int elapsed = millis() - blockStartTime;
      float progressRatio = (float)elapsed / totalSequenceDuration;
      b.drawProgressBar(constrain(progressRatio, 0, 1));
    }
  }
  // --- 再生ボタンの描画 ---
  textAlign(CENTER,CENTER);
  stroke(0, 255, 255);
  strokeWeight(2);
  fill(isMainPlaybackActive ? color(255, 100, 100) : color(0, 80, 120));
  rect(width/2 - 60, height - 60, 120, 40, 12);
  fill(0, 255, 255);
  noStroke();
  textSize(24);
  text("再生", width/2, height - 40);

  // --- 全体再生バーの描画 ---
 if (blockPlaying2D && fullSequenceDuration > 0) { // 条件をfullSequenceDurationに変更
    // ▼▼▼ この2行を変更 ▼▼▼
    long currentStepElapsed = millis() - blockStartTime;
    float progress = map(completedStepsDuration + currentStepElapsed, 0, fullSequenceDuration, 0, width);
    // ▲▲▲ ここまで変更 ▲▲▲
    stroke(255, 255, 0);
    strokeWeight(4);
    line(0, height - 5, constrain(progress, 0, width), height - 5);
  }
  // --- ドラッグ中のブロックの描画 ---
  if (draggingBlock2D != null) {
    draggingBlock2D.x = mouseX - dragOffsetX2D;
    draggingBlock2D.y = mouseY - dragOffsetY2D;
    draggingBlock2D.draw();
  }
  // drawCreateMode() 関数に追加

  // --- 右上に情報を表示 ---
  int blockCount = timelineBlocks2D.size();
  float totalDurationSeconds = fullSequenceDuration / 1000.0;

  String countText = "ブロック数: " + blockCount;
  String durationText = "合計時間: " + nf(totalDurationSeconds, 0, 2) + "秒";

  textSize(28);
  textAlign(RIGHT, TOP);

  color infoGlow = color(180);
  color infoText = color(255);

  // ブロック数の表示
  fill(infoGlow);
  for (int dx = -1; dx <= 1; dx++) text(countText, width - 20 + dx, 60);
  fill(infoText);
  text(countText, width - 20, 60);

  // 合計時間の表示
  fill(infoGlow);
  for (int dx = -1; dx <= 1; dx++) text(durationText, width - 20 + dx, 95);
  fill(infoText);
  text(durationText, width - 20, 95);
  drawCreateSequence();
}

/**
 * マウスが押された時の処理
 */
void handleCreateModePress() {
  if (handlePauseClick2()) return;

  for (int i = 0; i < materials.size(); i++) {
    AudioMaterial m = materials.get(i);
    int bx = 100 + i * 160;
    int by = 130;
    if (mouseX > bx && mouseX < bx + 140 && mouseY > by && mouseY < by + 30) {
      generate2_5DBlocks(m);
    }
  }

  if (mouseX > width/2 - 60 && mouseX < width/2 + 60 &&
      mouseY > height - 60 && mouseY < height - 20) {
    if (isMainPlaybackActive) {
      stopPlayback();
    } else {
      stopAllPreviews();
      playbackSequence = buildPlaybackSequence();
       fullSequenceDuration = 0;
     for (ArrayList<Block2_5D> step : playbackSequence) {
         long maxDurationInStep = 0;
         for (Block2_5D block : step) {
             if (block.durationMillis > maxDurationInStep) {
                 maxDurationInStep = block.durationMillis;
             }
         }
         fullSequenceDuration += maxDurationInStep;
     }
     completedStepsDuration = 0;

      if (!playbackSequence.isEmpty()) {
        currentPlaybackStep = 0;
        playStep(currentPlaybackStep);
        isMainPlaybackActive = true;
      }
    }
  }

  for (Block2_5D b : blockLibrary2D) {
    if (b.isPlayButtonClicked()) {
      stopPlayback();
      if (b.isPreviewPlaying) {
        b.stopPreview();
      } else {
        stopAllPreviews();
        b.playPreview();
      }
      return;
    }
    if (b.isMouseOver()) {
      draggingBlock2D = new Block2_5D(b.filePath, b.startMillis, b.durationMillis, b.x, b.y, b.depth, b.label);
      draggingFromLibrary2D = true;
      dragOffsetX2D = mouseX - b.x;
      dragOffsetY2D = mouseY - b.y;
      if (grabSound != null) {
        grabSound.rewind();
        grabSound.play();
      }
      return;
    }
  }

  for (Block2_5D b : timelineBlocks2D) {
    if (b.isMouseOver()) {
      draggingBlock2D = b;
      draggingFromLibrary2D = false;
      dragOffsetX2D = mouseX - b.x;
      dragOffsetY2D = mouseY - b.y;
      if (grabSound != null) {
        grabSound.rewind();
        grabSound.play();
      }
      return;
    }
  }
}

/**
 * マウスが離された時の処理
 */
void handleCreateModeRelease() {
  if (draggingBlock2D != null) {
    
     if (releaseSound != null) {
      releaseSound.rewind();
      releaseSound.play();
    }
    // タイムラインの枠内か判定
    boolean inTimelineArea = mouseY > height / 2 && mouseY < height - 100;

    // --- ▼ここからロジックを修正▼ ---

    // 1. ライブラリから新しいブロックをドラッグしてきた場合
    if (draggingFromLibrary2D) {
      if (inTimelineArea) {
        // 枠内なら、タイムラインにブロックを追加
        draggingBlock2D.depth = 0.3;
        timelineBlocks2D.add(draggingBlock2D);
      }
      // (枠外なら、何もしない。ブロックは просто消える)

    // 2. タイムライン上の既存ブロックをドラッグした場合
    } else {
      if (!inTimelineArea) {
        // 枠外にドロップされたら、タイムラインからブロックを削除
        timelineBlocks2D.remove(draggingBlock2D);
      }
      // (枠内なら、何もしない。位置の更新はドラッグ中に行われているため)
    }

    // --- ▲ここまでロジックを修正▲ ---

    // ドラッグ状態を終了
    draggingBlock2D = null;
     
    // ▼▼▼ ここから追加 ▼▼▼
    // 再生時間を再計算
    playbackSequence = buildPlaybackSequence();
    fullSequenceDuration = 0;
    for (ArrayList<Block2_5D> step : playbackSequence) {
        long maxDurationInStep = 0;
        for (Block2_5D block : step) {
            if (block.durationMillis > maxDurationInStep) {
                maxDurationInStep = block.durationMillis;
            }
        }
        fullSequenceDuration += maxDurationInStep;
    }
    // ▲▲▲ ここまで追加 ▲▲▲
  }
}

/**
 * マウスホイールの処理
 */
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  for (Block2_5D b : blockLibrary2D) {
    if (b.isMouseOver()) {
      b.adjustDepth(-e * 0.05);
    }
  }
  for (Block2_5D b : timelineBlocks2D) {
    if (b.isMouseOver()) {
      b.adjustDepth(-e * 0.05);
    }
  }
}

// =======================================================================
// ヘルパー関数 (補助的な処理)
// =======================================================================

/**
 * オーディオビジュアライザーの描画
 */
void drawVisualizer() {
  float centerX = width / 2;
  float centerY = height * 0.75 - 50; 

  pushMatrix();
  translate(centerX, centerY);

  if (visualizerPlayer != null && fft != null) {
    fft.forward(visualizerPlayer.mix);

    noFill();
    strokeWeight(3);
    float baseRadius = 80;

    for (int i = 0; i < fft.specSize(); i += 5) {
      float bandValue = fft.getBand(i);
      float angle = map(i, 0, fft.specSize(), 0, TWO_PI);
      float lineLength = map(bandValue, 0, 10, 0, 150);

      float x1 = cos(angle) * baseRadius;
      float y1 = sin(angle) * baseRadius;
      float x2 = cos(angle) * (baseRadius + lineLength);
      float y2 = sin(angle) * (baseRadius + lineLength);
      
      color c = lerpColor(color(0, 255, 255), color(255, 0, 255), lineLength / 150.0);
      stroke(c);
      line(x1, y1, x2, y2);
    }
  } else {
    noFill();
    float pulse = sin(millis() * 0.002) * 10;
    stroke(0, 255, 255, 150);
    strokeWeight(3);
    ellipse(0, 0, 160 + pulse, 160 + pulse);
  }
  popMatrix();
}

/**
 * 選択された素材からブロックライブラリを生成
 */
void generate2_5DBlocks(AudioMaterial m) {
  blockLibrary2D.clear();
  currentMaterialName = m.displayName;
  AudioPlayer tempPlayer = minim.loadFile(m.filePath);
  if (tempPlayer == null) return;

  int totalLength = tempPlayer.length();
  int blockCount = 8;
  int blockDuration = totalLength / blockCount;

  for (int i = 0; i < blockCount; i++) {
    int start = i * blockDuration;
    float x = 100 + i * 160;
    float y = 195;
    float depth = 0.8;
    
    String name = m.displayName;
    String abbreviatedName = (name.length() > 3) ? name.substring(0, 3) : name;
    String label = abbreviatedName + "_B" + (i + 1);
    
    blockLibrary2D.add(new Block2_5D(m.filePath, start, blockDuration, x, y, depth, label));
  }
  tempPlayer.close();
}

/**
 * タイムライン上のブロックから再生シーケンスを構築
 */
ArrayList<ArrayList<Block2_5D>> buildPlaybackSequence() {
  ArrayList<ArrayList<Block2_5D>> sequence = new ArrayList<>();
  if (timelineBlocks2D.isEmpty()) return sequence;

  ArrayList<Block2_5D> sortedBlocks = new ArrayList<>(timelineBlocks2D);
  sortedBlocks.sort((a, b) -> Float.compare(a.x, b.x));
  HashSet<Block2_5D> processedBlocks = new HashSet<>();
  
  ArrayList<Block2_5D> currentStepBlocks = new ArrayList<>();
  currentStepBlocks.add(sortedBlocks.get(0));
  processedBlocks.add(sortedBlocks.get(0));
  sequence.add(currentStepBlocks);

  while (!currentStepBlocks.isEmpty()) {
    ArrayList<Block2_5D> nextStepBlocks = new ArrayList<>();
    for (Block2_5D currentBlock : currentStepBlocks) {
      for (Block2_5D otherBlock : timelineBlocks2D) {
        if (!processedBlocks.contains(otherBlock) && otherBlock.x > currentBlock.x && abs(otherBlock.x - currentBlock.x) <= 160) {
          nextStepBlocks.add(otherBlock);
          processedBlocks.add(otherBlock);
        }
      }
    }
    if (nextStepBlocks.isEmpty()) break;
    sequence.add(nextStepBlocks);
    currentStepBlocks = nextStepBlocks;
  }
  return sequence;
}

/**
 * 指定されたステップのブロックを再生
 */
void playStep(int stepIndex) {
  for (AudioPlayer p : activeStepPlayers) {
    p.close();
  }
  activeStepPlayers.clear();

  if (stepIndex >= playbackSequence.size()) {
    stopPlayback();
    return;
  }

  ArrayList<Block2_5D> blocksToPlay = playbackSequence.get(stepIndex);
  long stepDuration = 0;

  for (Block2_5D b : blocksToPlay) {
    AudioPlayer p = minim.loadFile(b.filePath);
    p.setGain(map(b.depth, 0, 1, 0, -24));
    p.setPan(map(b.x, 0, width, -1, 1));
    p.cue(b.startMillis);
    p.play();
    activeStepPlayers.add(p);
    if (b.durationMillis > stepDuration) {
      stepDuration = b.durationMillis;
    }
  }
  
  if (!activeStepPlayers.isEmpty()) {
    visualizerPlayer = activeStepPlayers.get(0);
    fft = new FFT(visualizerPlayer.bufferSize(), visualizerPlayer.sampleRate());
  }
  
  totalSequenceDuration = (int)stepDuration;
  blockStartTime = millis();
  blockPlaying2D = true;
}

/**
 * 全ての再生を停止
 */
void stopPlayback() {
  for (AudioPlayer p : activeStepPlayers) {
    p.close();
  }
  activeStepPlayers.clear();
  blockPlaying2D = false;
  isMainPlaybackActive = false;
  visualizerPlayer = null;
}

/**
 * 再生シーケンスの更新
 */
void drawCreateSequence() {
  if (blockPlaying2D && isMainPlaybackActive) {
    int elapsed = millis() - blockStartTime;
    if (elapsed >= totalSequenceDuration) {
       completedStepsDuration += totalSequenceDuration;
      currentPlaybackStep++;
      playStep(currentPlaybackStep);
    }
  }
}

/**
 * 全てのプレビューを停止
 */
void stopAllPreviews() {
  for (Block2_5D b : blockLibrary2D) {
    b.stopPreview();
  }
}

// =======================================================================
// UI描画 / ポーズ画面の関数
// =======================================================================

void drawCreateModeMaterialButton(String label, float x, float y, float w, float h) {
  stroke(0, 255, 255);
  strokeWeight(2);
  fill(0, 50, 80);
  rect(x, y, w, h, 10);
  textAlign(CENTER, CENTER);
  float currentTextSize = 14;
  textSize(currentTextSize);
  while (textWidth(label) > w - 10 && currentTextSize > 8) {
    currentTextSize--;
    textSize(currentTextSize);
  }
  fill(0, 255, 255);
  noStroke();
  text(label, x + w / 2, y + h / 2);
  textSize(14);
}

void drawPauseButton2() {
  float x = width - 35;
  float y = 15;
  float h = 20;
  float gap = 5;
  float circleRadius = 18;
  strokeWeight(4);
  stroke(255, 255, 0, 150);
  noFill();
  circle(x, y + h/2, circleRadius * 2);
  strokeWeight(5);
  line(x - gap, y, x - gap, y + h);
  line(x + gap, y, x + gap, y + h);
  strokeWeight(2);
  stroke(255, 255, 0);
  noFill();
  circle(x, y + h/2, circleRadius * 2);
  strokeWeight(3);
  line(x - gap, y, x - gap, y + h);
  line(x + gap, y, x + gap, y + h);
}

void drawPauseOverlay2() {
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
  
  textSize(24); // ボタンのテキストサイズに戻す
  String[] buttons = {"再開", "素材選択", "復元モード", "タイトルへ戻る"};
  for (int i = 0; i < buttons.length; i++) {
    color buttonColor;
    color fillColor = color(10, 20, 40);
    switch (i) {
      case 0: buttonColor = color(0, 255, 128); break;
      case 1: buttonColor = color(0, 200, 255); break;
      case 2: buttonColor = color(255, 0, 255); break;
      case 3: buttonColor = color(255, 255, 0); break;
      default: buttonColor = color(200); break;
    }
    drawNeonButton(buttons[i], width/2 - 80, height/2 - 60 + i * 50, 160, 35, buttonColor, fillColor, 10);
  }
}

boolean handlePauseClick2() {
  if (!isPaused) return false;
  for (int i = 0; i < 4; i++) {
    int bx = width/2 - 80;
    int by = height/2 - 60 + i * 50;
    if (mouseX > bx && mouseX < bx + 160 && mouseY > by && mouseY < by + 35) {
      if (i == 0) {
        isPaused = false;
        for (AudioPlayer p : activeStepPlayers) {
            p.play();
        }
        for(Block2_5D b : blockLibrary2D) {
            if(b.wasPaused) {
                b.playPreview();
                b.wasPaused = false;
            }
        }
      } else if (i == 1) {
        isPaused = false;
        stopPlayback();
        currentMode = Mode.MATERIALS;
      } else if (i == 2) {
        isPaused = false;
        stopPlayback();
        currentMode = Mode.RESTORE;
      } else if (i == 3) {
        isPaused = false;
        stopPlayback();
        currentMode = Mode.START;
      }
      return true;
    }
  }
  return true;
}
