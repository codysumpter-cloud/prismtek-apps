#include <nds.h>
#include <stdio.h>

#define SCREEN_W 256
#define SCREEN_H 192
#define GROUND_Y 154
#define LEFT_RING 8
#define RIGHT_RING 248

typedef struct {
  int x, y;
  int vx, vy;
  int damage;
  int stocks;
  int meter;
  int facing;
  int cooldown;
  int awake;
  int color;
} Fighter;

static Fighter prism;
static Fighter rival;
static int roundDone = 0;
static int winner = 0;

static void reset_fighter(Fighter *f, int x, int color) {
  f->x = x;
  f->y = GROUND_Y;
  f->vx = 0;
  f->vy = 0;
  f->damage = 0;
  f->stocks = 3;
  f->meter = 0;
  f->facing = x < 128 ? 1 : -1;
  f->cooldown = 0;
  f->awake = 0;
  f->color = color;
}

static void reset_round(void) {
  reset_fighter(&prism, 72, RGB15(29, 17, 5));
  reset_fighter(&rival, 184, RGB15(8, 18, 31));
  roundDone = 0;
  winner = 0;
}

static void draw_rect(int x, int y, int w, int h, u16 color) {
  for (int py = 0; py < h; py++) {
    int yy = y + py;
    if (yy < 0 || yy >= SCREEN_H) continue;
    for (int px = 0; px < w; px++) {
      int xx = x + px;
      if (xx >= 0 && xx < SCREEN_W) VRAM_A[yy * SCREEN_W + xx] = color;
    }
  }
}

static void draw_bar(int x, int y, int w, int value, int max, u16 fill) {
  int filled = value > 0 ? (w * value) / max : 0;
  if (filled > w) filled = w;
  draw_rect(x, y, w, 5, RGB15(5, 4, 8));
  draw_rect(x, y, filled, 5, fill);
}

static void apply_move(Fighter *actor, Fighter *target, int power, int lift) {
  int dx = target->x - actor->x;
  if (dx * actor->facing < 0) return;
  if (dx < 0) dx = -dx;
  int dy = target->y - actor->y;
  if (dy < 0) dy = -dy;
  if (dx > 34 || dy > 24) return;
  int force = 10 + target->damage / 8 + power;
  target->vx += actor->facing * force;
  target->vy -= lift;
  target->damage += power;
  actor->meter += 8;
  if (actor->meter > 100) actor->meter = 100;
}

static void ringout(Fighter *f, int x) {
  f->stocks--;
  if (f->stocks <= 0) {
    roundDone = 1;
    winner = (f == &prism) ? 2 : 1;
    return;
  }
  f->x = x;
  f->y = GROUND_Y;
  f->vx = 0;
  f->vy = 0;
  f->damage = 0;
  f->awake = 0;
}

static void physics(Fighter *f) {
  f->vy += 1;
  f->x += f->vx >> 2;
  f->y += f->vy >> 2;
  f->vx = (f->vx * 13) >> 4;
  if (f->y >= GROUND_Y) {
    f->y = GROUND_Y;
    if (f->vy > 0) f->vy = 0;
  }
  if (f->cooldown > 0) f->cooldown--;
  if (f->awake > 0) f->awake--;
  if (f->x < LEFT_RING - 20 || f->x > RIGHT_RING + 20 || f->y > SCREEN_H + 12) {
    ringout(f, f == &prism ? 72 : 184);
  }
}

static void rival_ai(void) {
  if (roundDone) return;
  if (rival.x < prism.x) { rival.vx += 2; rival.facing = 1; }
  else { rival.vx -= 2; rival.facing = -1; }
  if (rival.y == GROUND_Y && prism.y < rival.y - 8) rival.vy = -18;
  if (rival.cooldown == 0) {
    apply_move(&rival, &prism, 7, 10);
    rival.cooldown = 34;
  }
}

static void handle_input(void) {
  scanKeys();
  int held = keysHeld();
  int down = keysDown();
  if (down & KEY_START) reset_round();
  if (roundDone) return;
  int speed = prism.awake ? 4 : 3;
  if (held & KEY_LEFT) { prism.vx -= speed; prism.facing = -1; }
  if (held & KEY_RIGHT) { prism.vx += speed; prism.facing = 1; }
  if ((down & KEY_UP) && prism.y == GROUND_Y) prism.vy = -22;
  if ((down & KEY_A) && prism.cooldown == 0) {
    apply_move(&prism, &rival, prism.awake ? 14 : 9, 12);
    prism.cooldown = prism.awake ? 18 : 28;
  }
  if ((down & KEY_B) && prism.cooldown == 0) {
    prism.vx += prism.facing * 42;
    apply_move(&prism, &rival, prism.awake ? 11 : 7, 7);
    prism.cooldown = 36;
  }
  if ((down & KEY_X) && prism.meter >= 100) {
    prism.awake = 360;
    prism.meter = 0;
  }
}

static void render(void) {
  for (int i = 0; i < SCREEN_W * SCREEN_H; i++) VRAM_A[i] = RGB15(4, 6, 12);
  draw_rect(LEFT_RING, GROUND_Y + 13, RIGHT_RING - LEFT_RING, 7, RGB15(18, 16, 10));
  draw_rect(50, 108, 54, 5, RGB15(16, 13, 8));
  draw_rect(152, 108, 54, 5, RGB15(16, 13, 8));
  draw_rect(prism.x - 7, prism.y - 17, 14, 18, prism.awake ? RGB15(31, 25, 4) : prism.color);
  draw_rect(rival.x - 7, rival.y - 17, 14, 18, rival.color);
  draw_bar(8, 8, 76, prism.damage, 180, RGB15(29, 17, 5));
  draw_bar(172, 8, 76, rival.damage, 180, RGB15(8, 18, 31));
  draw_bar(8, 16, 76, prism.meter, 100, RGB15(28, 25, 6));

  consoleClear();
  iprintf("Pixel Fruit Arena DS\n");
  iprintf("P stocks %d dmg %d%%\n", prism.stocks, prism.damage);
  iprintf("R stocks %d dmg %d%%\n", rival.stocks, rival.damage);
  iprintf("A move B dash X awaken\n");
  if (roundDone) iprintf(winner == 1 ? "Prism wins! START\n" : "Rival wins! START\n");
}

int main(void) {
  videoSetMode(MODE_FB0);
  vramSetBankA(VRAM_A_LCD);
  consoleDemoInit();
  reset_round();
  while (1) {
    handle_input();
    rival_ai();
    if (!roundDone) {
      physics(&prism);
      physics(&rival);
    }
    render();
    swiWaitForVBlank();
  }
  return 0;
}
