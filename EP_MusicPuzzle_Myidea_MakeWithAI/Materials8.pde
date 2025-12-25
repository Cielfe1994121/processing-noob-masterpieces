//Materials

import ddf.minim.*;
import java.util.HashSet; // HashSetのインポートを追加

ArrayList<AudioMaterial> materials = new ArrayList<AudioMaterial>();
AudioMaterial editingMaterial = null;
boolean isEditing = false;
AudioPlayer materialsBgm;

PFont materialsTitleFont, materialsDefaultFont;

void setupMaterials() {
  materialsTitleFont = createFont("SansSerif.bold", 28, true);
  materialsDefaultFont = createFont("SansSerif", 16, true);
}

void drawMaterialsTab() {
  drawMaterialsBackground();
  
  textFont(materialsTitleFont);
  textAlign(CENTER, TOP);
  
  textSize(72);
  String title = "素材置き場";
  float tx = width/2;
  float ty = 120;
  
 float t = millis() * 0.003; // アニメーション速度

  noStroke();
  // 1. 外側のぼやけたグロー（アニメーション付き）
  fill(0, 200, 200, 40 + 20 * sin(t)); // シアン系の光
  for(int i = 0; i < 5; i++) { // 複数回描画してぼかしを表現
    text(title, tx + random(-4, 4), ty + random(-4, 4));
  }

  // 2. 中間のグロー（はっきりした光）
  fill(50, 220, 220, 150); // 少し明るいシアンの光
  text(title, tx + 1, ty + 1);
  text(title, tx - 1, ty - 1);

  // 3. テキスト本体（ネオン管の中心）
  fill(0, 50, 80); // 元の深みのある本体色
  text(title, tx, ty);
  
  textFont(materialsDefaultFont);
  
  float listStartY = 220;
  float listSpacing = 50;
  for (int i = 0; i < materials.size(); i++) {
    AudioMaterial m = materials.get(i);
    m.y = int(listStartY + i * listSpacing);
    m.draw();
  }

  // --- ボタン類 ---
  float loadButtonY = height - 140;
  drawNeonButton("ファイル読み込み", width/2 - 80, loadButtonY, 160, 40, color(255, 255, 0), color(80, 80, 0), 10);

  float navButtonY = height - 70;
  float buttonWidth = 120;
  float buttonHeight = 35;
  float spacing = 15;
  float totalWidth = (buttonWidth * 3) + (spacing * 2);
  float startX = width/2 - totalWidth/2;

  // ★変更点：素材が読み込まれているかどうかのフラグ
  boolean canProceed = !materials.isEmpty();

  // 復元モードへボタン
  color restoreButtonColor = canProceed ? color(255, 0, 255) : color(100, 50, 100);
  color restoreFillColor = canProceed ? color(50, 0, 80) : color(30, 10, 30);
  drawNeonButton("復元モード", startX, navButtonY, buttonWidth, buttonHeight, restoreButtonColor, restoreFillColor, 10);

  // 創造モードへボタン
  color createButtonColor = canProceed ? color(0, 255, 128) : color(50, 100, 80);
  color createFillColor = canProceed ? color(0, 80, 60) : color(10, 30, 20);
  drawNeonButton("創造モード", startX + buttonWidth + spacing, navButtonY, buttonWidth, buttonHeight, createButtonColor, createFillColor, 10);
  
  // タイトルへ戻るボタン（常にアクティブ）
  drawNeonButton("タイトルへ戻る", startX + (buttonWidth + spacing) * 2, navButtonY, buttonWidth, buttonHeight, color(0, 255, 255), color(0, 50, 80), 10);

  if (isEditing && editingMaterial != null) {
    textFont(materialsDefaultFont);
    String displayText = editingMaterial.displayName == null ? "" : editingMaterial.displayName;
    
    String cursor = (millis() / 500) % 2 == 0 ? "_" : "";
    
    fill(0, 20, 30, 220);
    stroke(0, 255, 255);
    strokeWeight(2);
    rect(editingMaterial.x, editingMaterial.y + 45, editingMaterial.w, 30, 5);
    
    fill(0, 255, 255);
    noStroke();
    textAlign(LEFT, CENTER);
    text(displayText + cursor, editingMaterial.x + 10, editingMaterial.y + 60);
  }
}

void handleMaterialsClick() {
  float loadButtonY = height - 140;
  if (mouseX > width/2 - 80 && mouseX < width/2 + 80 &&
      mouseY > loadButtonY && mouseY < loadButtonY + 40) {
    selectInput("音声ファイルを選択してください", "fileSelected");
    return;
  }

  float navButtonY = height - 70;
  float buttonWidth = 120;
  float buttonHeight = 35;
  float spacing = 15;
  float totalWidth = (buttonWidth * 3) + (spacing * 2);
  float startX = width/2 - totalWidth/2;

  if (mouseY > navButtonY && mouseY < navButtonY + buttonHeight) {
    // ★変更点：素材がある場合のみ遷移するように条件を追加
    if (mouseX > startX && mouseX < startX + buttonWidth && !materials.isEmpty()) {
      currentMode = Mode.RESTORE;
      return;
    }
    if (mouseX > startX + buttonWidth + spacing && mouseX < startX + buttonWidth * 2 + spacing && !materials.isEmpty()) {
      currentMode = Mode.CREATE;
      return;
    }
    if (mouseX > startX + (buttonWidth + spacing) * 2 && mouseX < startX + totalWidth) {
      currentMode = Mode.START;
      return;
    }
  }

  isEditing = false;
  float listStartY = 220;
  float listSpacing = 50;
  for (int i = 0; i < materials.size(); i++) {
    AudioMaterial m = materials.get(i);
    float currentY = listStartY + i * listSpacing;
    if (mouseX > m.x && mouseX < m.x + m.w && mouseY > currentY && mouseY < currentY + m.h) {
      editingMaterial = m;
      isEditing = true;
      break;
    }
  }
}

void handleMaterialsKeyInput() {
  if (!isEditing || editingMaterial == null) return;
  
  if (editingMaterial.displayName == null) {
      editingMaterial.displayName = "";
  }

  if (key == ENTER || key == RETURN) {
    isEditing = false;
    return;
  }

  if (key == BACKSPACE) {
    if (editingMaterial.displayName.length() > 0) {
      editingMaterial.displayName = editingMaterial.displayName.substring(0, editingMaterial.displayName.length() - 1);
    }
    return;
  }
  
  if (Character.isDefined(key)) {
    editingMaterial.displayName += key;
  }
}

void fileSelected(File selection) {
  if (selection == null) return;

  String filePath = selection.getAbsolutePath();
  String fileName = selection.getName();
  
  int lastDot = fileName.lastIndexOf('.');
  if (lastDot > 0) {
    fileName = fileName.substring(0, lastDot);
  }
  
  int y = 100 + materials.size() * 60;

  AudioMaterial newMaterial = new AudioMaterial(filePath, fileName, width/2 - 150, y, 300, 40);
  materials.add(newMaterial);
  editingMaterial = newMaterial;
  isEditing = true;
}

class AudioMaterial {
  String filePath;
  String displayName;
  int x, y, w, h;

  AudioMaterial(String filePath, String displayName, int x, int y, int w, int h) {
    this.filePath = filePath;
    this.displayName = displayName;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void draw() {
    boolean isSelectedForEditing = (isEditing && editingMaterial != null && this.filePath.equals(editingMaterial.filePath));
    
    color neonColor = isSelectedForEditing ? color(255, 255, 0) : color(0, 255, 255);
    color fillColor = isSelectedForEditing ? color(80, 80, 0) : color(0, 50, 80);
    
    drawNeonButton(displayName, x, y, w, h, neonColor, fillColor, 10);
  }

  boolean isMouseOver() {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }
}
