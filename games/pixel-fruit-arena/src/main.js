import { bootGame } from './systems/game.js';

bootGame(document.getElementById('app')).catch((error) => {
  document.getElementById('app').innerHTML = `<section class="panel"><h1>Pixel Fruit Arena failed to boot</h1><pre>${error.stack}</pre></section>`;
});
