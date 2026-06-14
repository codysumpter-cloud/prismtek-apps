#include <nds.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct {
  int x, y;
  int vx, vy;
  int hp, maxHp;
  int charge;
} Top;

static Top player;
static Top rival;
static int roundNo = 1;
static int cash = 15;
static int gameOver = 0;
static int won = 0;
static int equipped[4] = {0, 0, 0, 0};
static int shopSlot = 0;
static int shopPart = 1;

enum { SLOT_RING, SLOT_CORE, SLOT_DRIVER, SLOT_CHIP };

typedef struct {
  int speed;
  int mass;
  int damage;
  int grip;
  int hp;
  int chargeRate;
  int cost;
} PartStats;

static PartStats part_stats(int slot, int index) {
  int tier = index / 16;
  int wobble = ((index * 17) % 11) - 5;
  PartStats p;
  p.speed = 14;
  p.mass = 10;
  p.damage = 7;
  p.grip = 242;
  p.hp = 100;
  p.chargeRate = 1;
  p.cost = 18 + tier * 55 + index * 4;
  if (slot == SLOT_RING) {
    p.speed += index / 5 + wobble;
    p.damage += index / 4 + tier * 3;
    p.mass += tier;
  } else if (slot == SLOT_CORE) {
    p.speed -= index / 18;
    p.mass += index / 3 + tier * 5;
    p.damage += index / 10;
    p.hp += index / 2 + tier * 10;
  } else if (slot == SLOT_DRIVER) {
    p.speed += index / 3 + tier * 2;
    p.grip += index / 8;
    p.chargeRate += tier;
  } else {
    p.damage += index / 7 + tier * 2;
    p.hp += index / 3;
    p.chargeRate += index / 18 + tier;
  }
  if (p.speed < 6) p.speed = 6;
  if (p.grip > 250) p.grip = 250;
  return p;
}

static PartStats build_stats(void) {
  PartStats s = {14, 10, 7, 242, 100, 1, 0};
  for (int slot = 0; slot < 4; slot++) {
    PartStats p = part_stats(slot, equipped[slot]);
    s.speed += p.speed - 14;
    s.mass += p.mass - 10;
    s.damage += p.damage - 7;
    s.grip += (p.grip - 242) / 4;
    s.hp += p.hp - 100;
    s.chargeRate += p.chargeRate - 1;
  }
  if (s.speed < 6) s.speed = 6;
  if (s.grip > 250) s.grip = 250;
  return s;
}

static void reset_round(void) {
  PartStats s = build_stats();
  player.x = 60; player.y = 96; player.vx = 0; player.vy = 0;
  player.maxHp = s.hp;
  player.hp = player.maxHp;
  player.charge = 0;
  rival.x = 196; rival.y = 96; rival.vx = 0; rival.vy = 0;
  rival.maxHp = 80 + roundNo * 18;
  rival.hp = rival.maxHp;
  rival.charge = 0;
}

static void start_run(void) {
  roundNo = 1;
  cash = 80;
  gameOver = 0;
  won = 0;
  for (int i = 0; i < 4; i++) equipped[i] = 0;
  shopSlot = 0;
  shopPart = 1;
  reset_round();
}

static void physics(Top *t) {
  PartStats s = build_stats();
  t->x += t->vx >> 4;
  t->y += t->vy >> 4;
  int grip = (t == &player) ? s.grip : 241;
  t->vx = (t->vx * grip) >> 8;
  t->vy = (t->vy * grip) >> 8;
  if (t->x < 18) { t->x = 18; t->vx = -t->vx; t->hp--; }
  if (t->x > 238) { t->x = 238; t->vx = -t->vx; t->hp--; }
  if (t->y < 26) { t->y = 26; t->vy = -t->vy; t->hp--; }
  if (t->y > 166) { t->y = 166; t->vy = -t->vy; t->hp--; }
}

static void collide(void) {
  PartStats s = build_stats();
  int dx = rival.x - player.x;
  int dy = rival.y - player.y;
  int dist2 = dx * dx + dy * dy;
  if (dist2 > 26 * 26) return;
  int shove = 12 + s.mass / 2 + player.charge / 5;
  if (dx < 0) shove = -shove;
  player.vx -= shove;
  rival.vx += shove;
  player.vy -= dy > 0 ? 10 : -10;
  rival.vy += dy > 0 ? 10 : -10;
  rival.hp -= s.damage / 2 + player.charge / 15;
  player.hp -= 2 + roundNo / 2;
  player.charge = 0;
}

static void draw_bar(int x, int y, int w, int value, int max, u16 color) {
  int fill = (value > 0) ? (w * value) / max : 0;
  for (int iy = 0; iy < 6; iy++) {
    for (int ix = 0; ix < w; ix++) {
      VRAM_A[(y + iy) * 256 + x + ix] = ix < fill ? color : RGB15(8, 3, 5);
    }
  }
}

static void draw_disc(int cx, int cy, int r, u16 color) {
  for (int y = -r; y <= r; y++) {
    for (int x = -r; x <= r; x++) {
      if (x * x + y * y <= r * r) {
        VRAM_A[(cy + y) * 256 + cx + x] = color;
      }
    }
  }
}

static void render(void) {
  for (int i = 0; i < 256 * 192; i++) VRAM_A[i] = RGB15(5, 7, 14);
  for (int y = 22; y < 174; y++) {
    VRAM_A[y * 256 + 16] = RGB15(31, 29, 20);
    VRAM_A[y * 256 + 240] = RGB15(31, 29, 20);
  }
  for (int x = 16; x <= 240; x++) {
    VRAM_A[22 * 256 + x] = RGB15(31, 29, 20);
    VRAM_A[174 * 256 + x] = RGB15(31, 29, 20);
  }
  draw_bar(18, 8, 86, player.hp, player.maxHp, RGB15(8, 28, 18));
  draw_bar(152, 8, 86, rival.hp, rival.maxHp, RGB15(31, 20, 4));
  draw_disc(player.x, player.y, 12, RGB15(8, 26, 31));
  draw_disc(rival.x, rival.y, 12, RGB15(31, 8, 12));

  consoleClear();
  iprintf("Round %d/12  Cash $%d\n", roundNo, cash);
  iprintf("Parts: R%02d C%02d D%02d S%02d\n", equipped[0], equipped[1], equipped[2], equipped[3]);
  iprintf("Shop slot %d part %02d $%d\n", shopSlot + 1, shopPart, part_stats(shopSlot, shopPart).cost);
  if (gameOver) iprintf(won ? "Champion! START restarts\n" : "Busted! START restarts\n");
  else iprintf("D-pad steer A charge\nL/R slot  X buy/equip\nCharge %d%%\n", player.charge);
}

int main(void) {
  videoSetMode(MODE_FB0);
  vramSetBankA(VRAM_A_LCD);
  consoleDemoInit();
  start_run();
  while (1) {
    scanKeys();
    int held = keysHeld();
    int down = keysDown();
    if (gameOver && (down & KEY_START)) start_run();
    if (!gameOver) {
      PartStats s = build_stats();
      if (down & KEY_L) shopSlot = (shopSlot + 3) % 4;
      if (down & KEY_R) shopSlot = (shopSlot + 1) % 4;
      if (down & KEY_X) {
        PartStats offer = part_stats(shopSlot, shopPart);
        if (cash >= offer.cost) {
          cash -= offer.cost;
          equipped[shopSlot] = shopPart;
          shopPart = (shopPart + 7 + roundNo) % 64;
          if (shopPart == 0) shopPart = 1;
          reset_round();
        }
      }
      if (held & KEY_LEFT) player.vx -= s.speed;
      if (held & KEY_RIGHT) player.vx += s.speed;
      if (held & KEY_UP) player.vy -= s.speed;
      if (held & KEY_DOWN) player.vy += s.speed;
      if (held & KEY_A && player.charge < 100) player.charge += s.chargeRate;
      if (rival.x < player.x) rival.vx += 3 + roundNo / 5; else rival.vx -= 3 + roundNo / 5;
      if (rival.y < player.y) rival.vy += 3 + roundNo / 5; else rival.vy -= 3 + roundNo / 5;
      physics(&player);
      physics(&rival);
      collide();
      if (rival.hp <= 0) {
        cash += 25 + roundNo * 12;
        roundNo++;
        shopPart = (shopPart + 5 + roundNo) % 64;
        if (shopPart == 0) shopPart = 1;
        if (roundNo > 12) { gameOver = 1; won = 1; }
        else reset_round();
      }
      if (player.hp <= 0) { gameOver = 1; won = 0; }
    }
    render();
    swiWaitForVBlank();
  }
  return 0;
}
