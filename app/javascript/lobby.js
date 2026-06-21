// ARCANA Card Battle — Lobby

function showPanel(type) {
  document.getElementById('mode-cards').style.display = 'none';
  document.getElementById('cpu-panel').classList.remove('visible');
  document.getElementById('online-panel').classList.remove('visible');
  document.getElementById(type + '-panel').classList.add('visible');
  if (type === 'online') generateCode();
}

function hidePanel(type) {
  document.getElementById('mode-cards').style.display = 'flex';
  document.getElementById(type + '-panel').classList.remove('visible');
}

function selectDiff(el, level) {
  document.querySelectorAll('.diff-btn').forEach(function (b) {
    b.classList.remove('active');
  });
  el.classList.add('active');
  document.getElementById('difficulty-input').value = level;
  document.getElementById('start-cpu-btn').classList.add('visible');
}

function switchRoomTab(tab) {
  document.getElementById('tab-create').classList.toggle('active', tab === 'create');
  document.getElementById('tab-join').classList.toggle('active', tab === 'join');
  document.getElementById('room-create').classList.toggle('visible', tab === 'create');
  document.getElementById('room-join').classList.toggle('visible', tab === 'join');
}

function generateCode() {
  var chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  var code = '';
  for (var i = 0; i < 4; i++) {
    code += chars[Math.floor(Math.random() * chars.length)];
  }
  document.getElementById('room-code').textContent = code;
}

function copyCode() {
  var code = document.getElementById('room-code').textContent;
  navigator.clipboard.writeText(code).then(function () {
    var btn = document.querySelector('.copy-btn');
    btn.textContent = 'コピーしました！';
    setTimeout(function () {
      btn.textContent = 'コードをコピー';
    }, 2000);
  });
}

// ---- グローバルに公開（onclick属性から呼べるようにする） ----
window.showPanel = showPanel;
window.hidePanel = hidePanel;
window.selectDiff = selectDiff;
window.switchRoomTab = switchRoomTab;
window.generateCode = generateCode;
window.copyCode = copyCode;