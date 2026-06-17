#include <nds.h>
#include <stdio.h>

#define SCREEN_W 256
#define SCREEN_H 192

typedef struct {
  int x, y;
  int vx, vy;
  int hp, maxHp;
  int cooldown;
  int dodge;
} Actor;

static Actor trainer;
static Actor companion;
static Actor wildling;
static int alphaMode = 0;
static int captured = 0;
static int contribution = 0;
static int messageTimer = 0;
static char message[40] = "Command your companion";

static void set_message(const char *text) {
  int i = 0;
  while (text[i] && i < 39) {
    message[i] = text[i];
    i++;
  }
  message[i] = 0;
  messageTimer = 90;
}

static void reset_actor(Actor *a, int x, int y, int hp) {
  a->x = x;
  a->y = y;
  a->vx = 0;
  a->vy = 0;
  a->hp = hp;
  a->maxHp = hp;
  a->cooldown = 0;
  a->dodge = 0;
}

static void reset_run(void) {
  reset_actor(&trainer, 52, 138, 100);
  reset_actor(&companion, 84, 132, 85);
  reset_actor(&wildling, 190, 116, alphaMode ? 240 : 130);
  captured = 0;
  contribution = 0;
  set_message(alphaMode ? "Alpha mode active" : "Wild encounter ready");
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

static int abs_i(int value) { return value < 0 ? -value : value; }

static void handle_input(void) {
  scanKeys();
  int held = keysHeld();
  int down = keysDown();

  if (down & KEY_START) reset_run();
  if (down & KEY_R) {
    alphaMode = !alphaMode;
    reset_run();
  }
  if (captured) return;

  if (held & KEY_LEFT) trainer.vx -= 3;
  if (held & KEY_RIGHT) trainer.vx += 3;
  if (held & KEY_UP) trainer.vy -= 3;
  if (held & KEY_DOWN) trainer.vy += 3;

  if ((down & KEY_B) && trainer.dodge == 0) {
    trainer.dodge = 32;
    trainer.vx += trainer.x < wildling.x ? -28 : 28;
    set_message("Trainer dodged");
  }

  if ((down & KEY_A) && companion.cooldown == 0) {
    int dx = wildling.x - companion.x;
    int dy = wildling.y - companion.y;
    int hit = abs_i(dx) < 64 && abs_i(dy) < 34;
    if (hit) {
      int amount = alphaMode ? 13 : 19;
      wildling.hp -= amount;
      contribution += amount;
      wildling.vx += dx > 0 ? 12 : -12;
      set_message("Companion move landed");
    } else {
      set_message("Move missed range");
    }
    companion.cooldown = 42;
  }

  if ((down & KEY_X) && wildling.hp < wildling.maxHp / 4) {
    int close = abs_i(trainer.x - wildling.x) < 34 && abs_i(trainer.y - wildling.y) < 34;
    if (close) {
      captured = 1;
      set_message(alphaMode ? "Alpha contained" : "Creature captured");
    } else {
      set_message("Move closer to capture");
    }
  }
}

static void physics_actor(Actor *a) {
  a->x += a->vx >> 2;
  a->y += a->vy >> 2;
  a->vx = (a->vx * 12) >> 4;
  a->vy = (a->vy * 12) >> 4;
  if (a->x < 16) a->x = 16;
  if (a->x > 240) a->x = 240;
  if (a->y < 28) a->y = 28;
  if (a->y > 168) a->y = 168;
  if (a->cooldown > 0) a->cooldown--;
  if (a->dodge > 0) a->dodge--;
}

static void companion_ai(void) {
  if (companion.x < trainer.x + 26) companion.vx += 2;
  if (companion.x > trainer.x + 38) companion.vx -= 2;
  if (companion.y < trainer.y - 10) companion.vy += 2;
  if (companion.y > trainer.y + 8) companion.vy -= 2;
}

static void wild_ai(void) {
  if (captured) return;
  int speed = alphaMode ? 3 : 2;
  if (wildling.x < companion.x) wildling.vx += speed; else wildling.vx -= speed;
  if (wildling.y < companion.y) wildling.vy += speed; else wildling.vy -= speed;
  if (abs_i(wildling.x - companion.x) < 20 && abs_i(wildling.y - companion.y) < 20 && companion.dodge == 0) {
    companion.hp -= alphaMode ? 2 : 1;
    if (companion.hp < 0) companion.hp = 0;
  }
  if (wildling.hp <= 0) {
    captured = 1;
    set_message(alphaMode ? "Alpha cleared" : "Wild cleared");
  }
}

static void update(void) {
  if (!captured) {
    companion_ai();
    wild_ai();
  }
  physics_actor(&trainer);
  physics_actor(&companion);
  physics_actor(&wildling);
  if (messageTimer > 0) messageTimer--;
}

static void render(void) {
  for (int i = 0; i < SCREEN_W * SCREEN_H; i++) VRAM_A[i] = RGB15(4, 9, 8);
  draw_rect(10, 30, 236, 138, RGB15(5, 12, 10));
  draw_rect(trainer.x - 5, trainer.y - 11, 10, 14, trainer.dodge ? RGB15(24, 24, 24) : RGB15(28, 22, 10));
  draw_rect(companion.x - 7, companion.y - 7, 14, 14, RGB15(8, 24, 17));
  draw_rect(wildling.x - 9, wildling.y - 9, 18, 18, alphaMode ? RGB15(28, 8, 26) : RGB15(15, 20, 8));
  draw_bar(8, 8, 82, companion.hp, companion.maxHp, RGB15(8, 24, 17));
  draw_bar(166, 8, 82, wildling.hp, wildling.maxHp, alphaMode ? RGB15(28, 8, 26) : RGB15(15, 20, 8));

  consoleClear();
  iprintf("TamerNet DS\n");
  iprintf("Companion %d/%d\n", companion.hp, companion.maxHp);
  iprintf("Wild %d/%d  Alpha %s\n", wildling.hp, wildling.maxHp, alphaMode ? "on" : "off");
  iprintf("Score %d\n", contribution);
  iprintf("A command B dodge X capture\nR alpha START reset\n");
  if (messageTimer > 0 || captured) iprintf("%s\n", message);
}

int main(void) {
  videoSetMode(MODE_FB0);
  vramSetBankA(VRAM_A_LCD);
  consoleDemoInit();
  reset_run();
  while (1) {
    handle_input();
    update();
    render();
    swiWaitForVBlank();
  }
  return 0;
}
