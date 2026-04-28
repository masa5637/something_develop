// ARCANA Card Battle — Battle logic

// ---- State ----
var selected = null;
var myTurn = true;
var p1hp = 80;
var p2hp = 38;
var monsterSlots = [true, false, false, false, false]; // index 0 = 炎の番人（初期配置済み）
var spellSlots   = [false, false, false, false, false];

// カードデータ（Railsでは DB から取得して埋め込む）
var cards = {
  shadow:  { type: 'monster', rune: '✦', name: '影の刺客', atk: 95, def: 20 },
  thunder: { type: 'monster', rune: '⚡', name: '雷神の剣',  atk: 60, def: 50 },
  fire:    { type: 'spell',   rune: '🔥', name: '炎の魔法' },
  shield:  { type: 'spell',   rune: '🛡', name: '鉄壁の守護' }
};

// ---- Card selection ----

function selectCard(id) {
  if (!myTurn) return;

  // 同じカードをもう一度タップで選択解除
  if (selected === id) {
    clearSelect();
    return;
  }

  if (selected) {
    document.getElementById('hc-' + selected).classList.remove('selected');
  }

  selected = id;
  document.getElementById('hc-' + id).classList.add('selected');

  var c = cards[id];
  if (c.type === 'monster') {
    document.getElementById('play-monster-btn').classList.add('visible');
    document.getElementById('play-spell-btn').classList.remove('visible');
    setLog('<span>' + c.name + '</span>を選択中 — モンスターゾーンに召喚できます');
  } else {
    document.getElementById('play-spell-btn').classList.add('visible');
    document.getElementById('play-monster-btn').classList.remove('visible');
    setLog('<span class="sp">' + c.name + '</span>を選択中 — 魔法ゾーンに発動できます');
  }
}

function clearSelect() {
  if (selected) {
    document.getElementById('hc-' + selected).classList.remove('selected');
  }
  selected = null;
  document.getElementById('play-monster-btn').classList.remove('visible');
  document.getElementById('play-spell-btn').classList.remove('visible');
  setLog('カードを選んで<span>モンスター召喚</span>か<span class="sp">魔法発動</span>してください');
}

// ---- Place monster ----

function playMonster() {
  if (!selected || cards[selected].type !== 'monster') return;
  var slot = monsterSlots.indexOf(false);
  if (slot === -1) { setLog('モンスターゾーンがいっぱいです'); return; }
  placeMonster(slot);
}

function placeMonster(slot) {
  if (!selected || !myTurn || cards[selected].type !== 'monster') return;
  monsterSlots[slot] = true;

  var c = cards[selected];
  var el = document.getElementById('ms' + slot);
  if (!el) return;

  el.className = 'fcard';
  el.onclick = null;
  el.id = '';
  el.innerHTML =
    '<div class="fcard-img"><span class="fcard-rune">' + c.rune + '</span></div>' +
    '<div class="fcard-footer">' +
      '<div class="fcard-name">' + c.name + '</div>' +
      '<div class="fcard-stats">' +
        '<span class="fstat a">A:' + c.atk + '</span>' +
        '<span class="fstat d">D:' + c.def + '</span>' +
      '</div>' +
    '</div>';

  document.getElementById('hc-' + selected).remove();
  setLog('<span>' + c.name + '</span>を召喚した！');
  clearSelect();
}

// ---- Place spell ----

function playSpell() {
  if (!selected || cards[selected].type !== 'spell') return;
  var slot = spellSlots.indexOf(false);
  if (slot === -1) { setLog('魔法ゾーンがいっぱいです'); return; }
  placeSpell(slot);
}

function placeSpell(slot) {
  if (!selected || !myTurn || cards[selected].type !== 'spell') return;
  if (spellSlots[slot]) return;
  spellSlots[slot] = true;

  var c = cards[selected];
  var el = document.getElementById('sz' + slot);
  el.className = 'scard filled';
  el.onclick = null;
  el.innerHTML =
    '<span class="scard-icon">' + c.rune + '</span>' +
    '<span class="scard-label">' + c.name + '</span>';

  document.getElementById('hc-' + selected).remove();
  setLog('<span class="sp">' + c.name + '</span>を魔法ゾーンに発動！');
  clearSelect();
}

// ---- Turn management ----

function endTurn() {
  myTurn = false;
  clearSelect();
  document.getElementById('turn-badge').textContent = '相手のターン';
  document.getElementById('turn-badge').classList.remove('my-turn');
  setLog('相手のターンです…');
  setTimeout(function () { enemyAttack(); }, 1200);
}

function enemyAttack() {
  var dmg = Math.floor(Math.random() * 20) + 10;
  p1hp = Math.max(0, p1hp - dmg);
  updateHp('p1', p1hp, 100);
  setLog('相手の<span>氷壁の騎士</span>が攻撃！ <span>' + dmg + 'ダメージ</span>を受けた');

  setTimeout(function () {
    myTurn = true;
    document.getElementById('turn-badge').textContent = 'あなたのターン';
    document.getElementById('turn-badge').classList.add('my-turn');
    setLog('あなたのターンです。カードを選んでください');
  }, 1500);
}

// ---- HP update ----

function updateHp(who, current, max) {
  var pct = Math.round(current / max * 100);
  var bar = document.getElementById(who + '-bar');
  var num = document.getElementById(who + '-hp');
  bar.style.width = pct + '%';
  bar.className = 'hp-bar-fill ' + (pct > 60 ? 'high' : pct > 30 ? 'mid' : 'low');
  num.textContent = current + ' / ' + max;
}

// ---- Log ----

function setLog(html) {
  document.getElementById('log').innerHTML = html;
}