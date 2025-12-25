//EP_Puzzle
import ddf.minim.*;

enum Mode { START, MATERIALS, RESTORE, CREATE }
Mode currentMode = Mode.START;

PFont uiFont;
Minim minim;
AudioPlayer blockPlayer2D;
AudioPlayer restorePlayer;

// BGMプレイヤー
AudioPlayer startBGM;
AudioPlayer materialsBGM;

//isPaused == false;

// ▼▼▼ ここから追加 ▼▼▼
// --- BGM音量管理 ---
float bgmVolume = 0.7; // BGMの音量 (0.0 ~ 1.0)
boolean isMuted = false;
// ▲▲▲ ここまで追加 ▲▲▲

void setup() {
  size(1000, 600);
  uiFont = createFont("SansSerif", 32);
  textFont(uiFont);
  minim = new Minim(this);
  setupMaterials();
  startSound = minim.loadFile("Suiteki2.mp3", 2048);
  grabSound = minim.loadFile("Suiteki1.mp3");
  releaseSound = minim.loadFile("Suiteki2.mp3");
}

void draw() {
  background(255);
  drawTabs();

  // BGM制御
  handleBGM();

  switch(currentMode) {
    case START:
      drawStartScreen();
      break;
    case MATERIALS:
      drawMaterialsTab();
      break;
    case RESTORE:
      if (isPaused) {
        drawPauseOverlay();
      } else {
        drawRestoreMode();
      }
      break;
    case CREATE:
      if (isPaused) {
        drawPauseOverlay2();
      } else {
        drawCreateMode();
        drawCreateSequence();
      }
      break;
  }
  
  // ▼▼▼ ここから追加 ▼▼▼
  // BGMが再生される可能性のある画面で音量調整UIを描画
  if (currentMode == Mode.START || currentMode == Mode.MATERIALS || (currentMode == Mode.RESTORE && !restoreGameStarted && !isCountdownActive)) {
    drawVolumeControls();
  }
  // ▲▲▲ ここまで追加 ▲▲▲
}

void handleBGM() {
  if (currentMode == Mode.START) {
    if (startBGM == null) {
      startBGM = minim.loadFile("Suityuu.mp3", 2048);
      startBGM.loop();
      updateBgmVolume(); // ▼追加
    }
    if (materialsBGM != null) {
      materialsBGM.close();
      materialsBGM = null;
    }
  } else if (currentMode == Mode.MATERIALS) {
    if (materialsBGM == null) {
      materialsBGM = minim.loadFile("Suityuu2.mp3", 2048);
      materialsBGM.loop();
      updateBgmVolume(); // ▼追加
    }
    if (startBGM != null) {
      startBGM.close();
      startBGM = null;
    }
  } else {
    if (startBGM != null) {
      startBGM.close();
      startBGM = null;
    }
    if (materialsBGM != null) {
      materialsBGM.close();
      materialsBGM = null;
    }
  }
}

// ▼▼▼ mousePressed関数を修正 ▼▼▼
void mousePressed() {
  handleTabClick(); // 元のコードのまま、最初にタブのクリックを処理

  // ▼音量UIのクリック判定を追加▼
  if (currentMode == Mode.START || currentMode == Mode.MATERIALS || (currentMode == Mode.RESTORE && !restoreGameStarted)) {
    if (handleVolumeControlsPress()) {
      return; // 音量UIが操作されたら、他の処理は行わない
    }
  }

  switch(currentMode) {
    case START:
      handleStartScreenClick();
      break;
    case MATERIALS:
      handleMaterialsClick();
      break;
    case RESTORE:
      if (!handlePauseClick()) {
        handleRestoreModeClick();
      }
      break;
    case CREATE:
      if (!handlePauseClick2()) {
        handleCreateModePress();
      }
      break;
  }
}
// ▲▲▲ mousePressed関数を修正 ▲▲▲

// ▼▼▼ mouseDragged関数を新設 ▼▼▼
void mouseDragged() {
  if (currentMode == Mode.START || currentMode == Mode.MATERIALS || (currentMode == Mode.RESTORE && !restoreGameStarted)) {
    handleVolumeSliderDrag();
  }
}
// ▲▲▲ mouseDragged関数を新設 ▲▲▲

void mouseReleased() {
  switch(currentMode) {
    case MATERIALS:
      // handleMaterialsRelease();
      break;
    case RESTORE:
      handleRestoreMouseRelease();
      break;
    case CREATE:
      handleCreateModeRelease();
      break;
  }
}

void keyPressed() {
  handleMaterialsKeyInput();
}

// ▼▼▼ ここから下の関数をすべて追加 ▼▼▼

/**
 * BGM音量調整UIを左下に描画する
 */
void drawVolumeControls() {
  float margin = 15;
  
  // --- ミュートボタン ---
  float muteBtnY = height - margin - 25;
  String muteLabel = isMuted ? "MUTE ON" : "MUTE";
  color muteColor = isMuted ? color(255, 100, 100) : color(0, 255, 128);
  color muteFill = isMuted ? color(80, 20, 20) : color(0, 80, 60);
  drawNeonButton(muteLabel, margin, muteBtnY, 90, 20, muteColor, muteFill, 8);
  
  // --- 音量スライダー ---
  float sliderY = height - margin - 25 - 20;
  float sliderX = margin;
  float sliderW = 150;
  float sliderH = 10;
  
  noStroke();
  fill(80, 80, 0, 200);
  rect(sliderX, sliderY, sliderW, sliderH, 5);
  
  fill(255, 220, 0);
  rect(sliderX, sliderY, sliderW * bgmVolume, sliderH, 5);
  
  stroke(255, 255, 150);
  strokeWeight(2);
  fill(isMuted ? color(100) : color(255, 220, 0));
  circle(sliderX + sliderW * bgmVolume, sliderY + sliderH / 2, 16);

  // --- 音量ラベル ---
  float labelY = height - margin - 25 - 20 - 25;
  textAlign(LEFT, TOP);
  textSize(16);
  noStroke();
  fill(200, 180, 0, 180);
  text("音量", margin + 1, labelY + 1);
  fill(255, 255, 150);
  text("音量", margin, labelY);
}

/**
 * マウスドラッグ時のスライダー操作
 */
void handleVolumeSliderDrag() {
  float margin = 15;
  float sliderX = margin;
  float sliderY = height - margin - 25 - 20;
  float sliderW = 150;
  float sliderH = 10;
  
  if (mouseY > sliderY - 10 && mouseY < sliderY + sliderH + 10 && mouseX > sliderX -10 && mouseX < sliderX + sliderW + 10) {
    float newVolume = (mouseX - sliderX) / sliderW;
    bgmVolume = constrain(newVolume, 0.0, 1.0);
    updateBgmVolume();
  }
}

/**
 * マウスクリック時のUI操作
 * @return boolean UIが操作されたか
 */
boolean handleVolumeControlsPress() {
  float margin = 15;
  
  // ミュートボタンの判定
  float muteBtnY = height - margin - 25;
  if (mouseX > margin && mouseX < margin + 90 && mouseY > muteBtnY && mouseY < muteBtnY + 20) {
    isMuted = !isMuted;
    updateBgmVolume();
    return true;
  }
  
  // スライダーの判定
  float sliderX = margin;
  float sliderY = height - margin - 25 - 20;
  float sliderW = 150;
  if (mouseX > sliderX && mouseX < sliderX + sliderW && mouseY > sliderY - 10 && mouseY < sliderY + 20) {
    handleVolumeSliderDrag();
    return true;
  }
  
  return false;
}

/**
 * 現在の音量設定をBGMプレイヤーに適用する
 */
void updateBgmVolume() {
  float gain = map(bgmVolume, 0.0, 1.0, -80.0, 0.0);

  AudioPlayer[] bgmPlayers = {startBGM, materialsBGM, restoreBGM};
  
  for (AudioPlayer player : bgmPlayers) {
    if (player != null) {
      if (isMuted) {
        player.mute();
      } else {
        player.unmute();
        player.setGain(gain);
      }
    }
  }
}
// ▲▲▲ ここまで追加 ▲▲▲
