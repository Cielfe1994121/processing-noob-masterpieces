//StartScreen

import java.util.HashSet; // 念のためインポート

PFont jpFont;
AudioPlayer startBgm;

void setupStartScreenFont() {
  jpFont = createFont("SansSerif", 32,true);
  textFont(jpFont);
}

void drawStartScreen() {
  drawStartScreenBackground();
  setupStartScreenFont();
  textAlign(CENTER, CENTER);

textSize(72);
  String title = "Mus!c Blocks : Neons";
  float tx = width / 2;
  float ty = height / 2 - 130;
  float t = millis() * 0.003; // アニメーション速度を調整

  noStroke();
  // 1. 外側のぼやけたグロー（アニメーション付き）
  // 変更点: 外枠の色をより白寄りに調整
  fill(255, 240, 180, 40 + 20 * sin(t)); // 明るいクリームイエロー
  for(int i = 0; i < 5; i++) { // 複数回描画してぼかしを表現
    text(title, tx + random(-4, 4), ty + random(-4, 4));
  }

  // 2. 中間のグロー（はっきりした光）
  fill(255, 220, 50, 150);
  text(title, tx + 1, ty + 1);
  text(title, tx - 1, ty - 1);

  // 3. テキスト本体（ネオン管の中心）
  fill(255, 255, 220); // ほぼ白に近いクリーム色
  text(title, tx, ty);
  // --- ▲ ここまで修正 ▲ ---

  // --- ▼ サブタイトルの追加 ▼ ---
  textSize(24); // サブタイトルのフォントサイズ
  String subtitle = "～創造と復元。2つの音楽体験～";
  float sub_ty = ty + 60; // タイトルの少し下に配置

  // 1. グロー（ぼかし効果）
  fill(255, 200, 0, 80);
  text(subtitle, tx + 1, sub_ty + 1);
  text(subtitle, tx - 1, sub_ty - 1);

  // 2. テキスト本体
  fill(255, 255, 220); // メインタイトルと同じ色
  text(subtitle, tx, sub_ty);
  // --- ▲ ここまで追加 ▲ ---

  // --- ボタン ---
  textSize(16);
  float buttonX = width / 2 - 75;
  float buttonW = 150;
  float buttonH = 40;

  boolean canProceed = !materials.isEmpty();

  // --- 復元モードへ ---
  float restoreButtonY = height / 2 - 20;
  // ▼ 配色をシアンに戻す
  color restoreBtnColor = canProceed ? color(0, 255, 255) : color(50, 100, 100);
  color restoreFillColor = canProceed ? color(0, 50, 80) : color(10, 20, 20);
  drawNeonButton("復元モード", buttonX, restoreButtonY, buttonW, buttonH, restoreBtnColor, restoreFillColor, 10);
  
  if(highScore != 0)
  {
   textSize(28);
   String highScoreText = "H! SCORE: " + highScore;
   color honorColor = color(255, 255, 0);
   for (int dx = -1; dx <= 1; dx++) text(highScoreText, width/2 + 200 + dx, height/2  + dx);
   fill(honorColor);
   text(highScoreText, width/2 + 200 , height/2 );
  }
  
  textSize(16);
  // --- 創造モードへ ---
  float createButtonY = height / 2 + 40;
  // ▼ 配色をネオングリーンに戻す
  color createBtnColor = canProceed ? color(0, 255, 128) : color(50, 100, 80);
  color createFillColor = canProceed ? color(0, 80, 60) : color(10, 30, 20);
  drawNeonButton("創造モード", buttonX, createButtonY, buttonW, buttonH, createBtnColor, createFillColor, 10);

  // --- 素材置き場へ ---
  float materialsButtonY = height / 2 + 100;
  // ▼ 配色を変更 (Cyan -> Magenta)
  drawNeonButton("素材置き場", buttonX, materialsButtonY, buttonW, buttonH, color(255, 0, 255), color(50, 0, 80), 10);
}

void handleStartScreenClick() {
  float buttonX = width / 2 - 75;
  float buttonW = 150;
  
  if (mouseX > buttonX && mouseX < buttonX + buttonW) {
    // ★変更点：素材がある場合のみ遷移する
    if (mouseY > height / 2 - 20 && mouseY < height / 2 + 20 && !materials.isEmpty()) {
      currentMode = Mode.RESTORE;
    } else if (mouseY > height / 2 + 40 && mouseY < height / 2 + 80 && !materials.isEmpty()) {
      currentMode = Mode.CREATE;
    } else if (mouseY > height / 2 + 100 && mouseY < height / 2 + 140) {
      currentMode = Mode.MATERIALS;
    }
  }
}

/**
 * 他のモードと共通のネオンスタイルボタンを描画するヘルパー関数
 */
void drawNeonButton3(String label, float x, float y, float w, float h, color neonColor, color fillColor, float cornerRadius) {
  noFill();
  stroke(neonColor, 150);
  strokeWeight(5);
  rect(x, y, w, h, cornerRadius);

  fill(fillColor);
  noStroke();
  rect(x, y, w, h, cornerRadius);

  textAlign(CENTER, CENTER);
  
  float currentTextSize = 16;
  textSize(currentTextSize);
  while (textWidth(label) > w - 10 && currentTextSize > 8) {
    currentTextSize--;
    textSize(currentTextSize);
  }
  
  fill(neonColor);
  text(label, x + w / 2, y + h / 2);
  
  textSize(16);
}
