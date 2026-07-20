/**
 * UI building blocks for PBS Editor v2.
 */

import { TYPE_COLORS } from './file-types.js';

let _t = s => s;
export function setI18n(tFn) { _t = tFn; }

// ---- SVG preview icons (48px, Lucide-style) ----
const _previewSvg = (d) => `<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="opacity:0.5">${d}</svg>`;
const ICON_PREVIEW    = _previewSvg('<rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><path d="m21 15-5-5L5 21"/>');
const ICON_LOADING    = _previewSvg('<path d="M21 12a9 9 0 1 1-6.219-8.56"/>');
const ICON_NOT_FOUND = _previewSvg('<circle cx="12" cy="12" r="10"/><path d="m4.93 4.93 14.14 14.14"/>');

// ---- Type icon sprite (loaded from game project) ----
let _typeIconUrl = null;
let _typeIconW = 0;
let _typeIconH = 0;
let _typeIconTotalH = 0;

const TYPE_ICON_DISP_H = 20; // display height in list rows

export function configureTypeIcons(url, iconW, iconH, totalH) {
  _typeIconUrl = url;
  _typeIconW = iconW;
  _typeIconH = iconH;
  _typeIconTotalH = totalH;
}

export function clearTypeIcons() {
  _typeIconUrl = null;
  _typeIconW = 0;
  _typeIconH = 0;
  _typeIconTotalH = 0;
}

export function getTypeIconConfig() {
  return _typeIconUrl ? { url: _typeIconUrl, iconW: _typeIconW, iconH: _typeIconH, totalH: _typeIconTotalH } : null;
}

function typeIconStyle(iconPos, dispH) {
  const dH = dispH || TYPE_ICON_DISP_H;
  const scale = _typeIconH > 0 ? dH / _typeIconH : 1;
  const dispW = Math.round(_typeIconW * scale);
  const dispTotalH = Math.round(_typeIconTotalH * scale);
  return {
    display: 'inline-block',
    width: dispW + 'px',
    height: dH + 'px',
    backgroundImage: `url(${_typeIconUrl})`,
    backgroundPosition: `0 -${iconPos * dH}px`,
    backgroundRepeat: 'no-repeat',
    backgroundSize: `${dispW}px ${dispTotalH}px`,
    imageRendering: 'pixelated',
    flexShrink: '0',
    alignSelf: 'center',
  };
}

function makeTypeIndicator(typeName, iconPos) {
  if (_typeIconUrl && iconPos != null) {
    return h('span', { style: typeIconStyle(iconPos) });
  }
  const color = TYPE_COLORS[(typeName || '').toUpperCase()] || null;
  return h('span', { style: {
    display: 'inline-block',
    width: '10px',
    height: '10px',
    borderRadius: '2px',
    background: color || 'var(--border)',
    flexShrink: '0',
    alignSelf: 'center',
    border: '1px solid ' + (color ? color + '66' : 'var(--border)'),
  }});
}

function updateTypeIndicator(el, typeName, iconPos) {
  if (_typeIconUrl && iconPos != null) {
    Object.assign(el.style, typeIconStyle(iconPos));
    el.style.background = '';
    el.style.border = '';
    el.style.borderRadius = '';
  } else {
    const color = TYPE_COLORS[(typeName || '').toUpperCase()] || null;
    el.style.backgroundImage = '';
    el.style.backgroundPosition = '';
    el.style.backgroundSize = '';
    el.style.width = '10px';
    el.style.height = '10px';
    el.style.borderRadius = '2px';
    el.style.background = color || 'var(--border)';
    el.style.border = '1px solid ' + (color ? color + '66' : 'var(--border)');
  }
}

// ---- Element helper ----
export function h(tag, attrs, ...children) {
  const el = document.createElement(tag);
  if (attrs) {
    for (const [k, v] of Object.entries(attrs)) {
      if (k === 'style' && typeof v === 'object') Object.assign(el.style, v);
      else if (k.startsWith('on')) el.addEventListener(k.slice(2).toLowerCase(), v);
      else if (k === 'className') el.className = v;
      else if (k === 'textContent') el.textContent = v;
      else if (k === 'innerHTML') el.innerHTML = v;
      else if (k === 'dataset') Object.assign(el.dataset, v);
      else if (k === 'selected' || k === 'disabled' || k === 'checked' || k === 'multiple' || k === 'readOnly') { if (v) el[k] = true; }
      else el.setAttribute(k, v);
    }
  }
  for (const c of children) {
    if (c == null || c === false) continue;
    if (typeof c === 'string' || typeof c === 'number') el.appendChild(document.createTextNode(String(c)));
    else if (c instanceof Node) el.appendChild(c);
  }
  return el;
}

export function button(label, onClick, variant = '') {
  const cls = `pbs-btn ${variant}`;
  return label && typeof label === 'string' && label.includes('<')
    ? h('button', { className: cls, onClick, innerHTML: label })
    : h('button', { className: cls, onClick, textContent: label });
}

export function badge(text) {
  return h('span', { className: 'pbs-sidebar-badge', textContent: String(text) });
}

export function searchBox(placeholder, onInput) {
  let timer;
  const input = h('input', { className: 'pbs-search', type: 'text', placeholder: placeholder || _t('Search...'), onInput: () => { clearTimeout(timer); timer = setTimeout(() => onInput(input.value), 150); } });
  return input;
}

// ---- Pagination ----
export function createPagination(onPage) {
  let current = 0;
  let totalPages = 1;
  const container = h('div', { className: 'pbs-pagination' });
  const prevBtn = h('button', { className: 'pbs-page-btn', textContent: _t('← Prev'), onClick: () => { if (current > 0) { current--; update(); onPage(current); } } });
  const info = h('span', { textContent: '' });
  const nextBtn = h('button', { className: 'pbs-page-btn', textContent: _t('Next →'), onClick: () => { if (current < totalPages - 1) { current++; update(); onPage(current); } } });
  container.appendChild(prevBtn);
  container.appendChild(info);
  container.appendChild(nextBtn);

  function update() {
    prevBtn.disabled = current <= 0;
    nextBtn.disabled = current >= totalPages - 1;
    info.textContent = _t('Page {current} of {total}', { current: current + 1, total: totalPages });
  }
  function setTotal(total) { totalPages = Math.max(1, total); if (current >= totalPages) current = totalPages - 1; update(); }
  function getPage() { return current; }
  function reset() { current = 0; update(); }

  function _forcePage(p) { current = Math.max(0, Math.min(p, totalPages - 1)); update(); }

  update();
  return { el: container, setTotal, getPage, reset, _forcePage };
}

// ---- Preview panel ----
let _animFrame = null;
let _animInterval = null;

export function createPreviewPanel(loadImageFn) {
  const panel = h('div', { className: 'pbs-preview' });
  const placeholder = h('div', { className: 'pbs-preview-placeholder' });
  placeholder.appendChild(h('div', { className: 'pbs-preview-placeholder-icon', innerHTML: ICON_PREVIEW }));
  placeholder.appendChild(h('div', { textContent: _t('Select an entry to preview') }));
  panel.appendChild(placeholder);

  function stopAnim() {
    if (_animInterval) { clearInterval(_animInterval); _animInterval = null; }
  }

  function show(gameRoot, path, displayName, fps, opts = {}) {
    stopAnim();
    panel.innerHTML = '';
    if (!path) {
      const ph = h('div', { className: 'pbs-preview-placeholder' });
      ph.appendChild(h('div', { className: 'pbs-preview-placeholder-icon', innerHTML: ICON_PREVIEW }));
      ph.appendChild(h('div', { textContent: _t('No graphic') }));
      panel.appendChild(ph);
      panel.appendChild(h('div', { className: 'pbs-preview-name', textContent: displayName || '' }));
      return;
    }
    if (!loadImageFn) {
      const ph = h('div', { className: 'pbs-preview-placeholder' });
      ph.appendChild(h('div', { className: 'pbs-preview-placeholder-icon', innerHTML: ICON_PREVIEW }));
      ph.appendChild(h('div', { textContent: _t('No loader') }));
      panel.appendChild(ph);
      panel.appendChild(h('div', { className: 'pbs-preview-name', textContent: displayName || '' }));
      return;
    }
    const absPath = (gameRoot || '').replace(/\\/g, '/') + '/' + path;
    const loading = h('div', { className: 'pbs-preview-placeholder' });
    loading.appendChild(h('div', { className: 'pbs-preview-placeholder-icon', innerHTML: ICON_LOADING }));
    loading.appendChild(h('div', { textContent: _t('Loading...') }));
    panel.appendChild(loading);

    const panelName = displayName || '';
    const animFps = fps || 16;

    loadImageFn(absPath).then(url => {
      if (!url) {
        panel.innerHTML = '';
        const ph = h('div', { className: 'pbs-preview-placeholder' });
        ph.appendChild(h('div', { className: 'pbs-preview-placeholder-icon', innerHTML: ICON_NOT_FOUND }));
        ph.appendChild(h('div', { textContent: path.split('/').pop() }));
        ph.appendChild(h('div', { textContent: _t('Not found'), style: { fontSize: '10px' } }));
        panel.appendChild(ph);
        panel.appendChild(h('div', { className: 'pbs-preview-name', textContent: panelName }));
        return;
      }
      const img = new Image();
      img.onload = () => {
        panel.innerHTML = '';
        const frameH = img.naturalHeight;
        const totalW = img.naturalWidth;
        const frameCount = Math.max(1, Math.round(totalW / frameH));
        const isSpritesheet = !opts.map && frameCount > 1 && totalW > frameH;

        if (isSpritesheet) {
          const size = Math.min(128, frameH * 2);
          const canvas = h('canvas', { width: size, height: size, style: { imageRendering: 'pixelated', borderRadius: '4px'} });
          const ctx2d = canvas.getContext('2d');
          ctx2d.imageSmoothingEnabled = false;
          let currentFrame = 0;
          panel.appendChild(canvas);
          panel.appendChild(h('div', { className: 'pbs-preview-name', textContent: panelName + ` (${frameCount}f)` }));

          function drawFrame() {
            ctx2d.clearRect(0, 0, size, size);
            ctx2d.drawImage(img, currentFrame * frameH, 0, frameH, frameH, 0, 0, size, size);
          }
          drawFrame();
          if (animFps > 0) {
            const delayMs = Math.max(16, Math.round(1000 / animFps));
            _animInterval = setInterval(() => {
              currentFrame = (currentFrame + 1) % frameCount;
              drawFrame();
            }, delayMs);
          }
        } else {
          panel.appendChild(h('img', { className: 'pbs-preview-img' + (opts.map ? ' pbs-preview-map' : ''), src: url, alt: panelName }));
          panel.appendChild(h('div', { className: 'pbs-preview-name', textContent: panelName }));
        }
      };
      img.onerror = () => {
        panel.innerHTML = '';
        const ph = h('div', { className: 'pbs-preview-placeholder' });
        ph.appendChild(h('div', { className: 'pbs-preview-placeholder-icon', innerHTML: ICON_NOT_FOUND }));
        ph.appendChild(h('div', { textContent: path.split('/').pop() }));
        panel.appendChild(ph);
        panel.appendChild(h('div', { className: 'pbs-preview-name', textContent: panelName }));
      };
      img.src = url;
    }).catch(() => {
      panel.innerHTML = '';
      const ph = h('div', { className: 'pbs-preview-placeholder' });
      ph.appendChild(h('div', { className: 'pbs-preview-placeholder-icon', innerHTML: ICON_NOT_FOUND }));
      ph.appendChild(h('div', { textContent: path.split('/').pop() }));
      panel.appendChild(ph);
      panel.appendChild(h('div', { className: 'pbs-preview-name', textContent: panelName }));
    });
  }

  function clear() {
    stopAnim();
    panel.innerHTML = '';
    const ph = h('div', { className: 'pbs-preview-placeholder' });
    ph.appendChild(h('div', { className: 'pbs-preview-placeholder-icon', innerHTML: ICON_PREVIEW }));
    ph.appendChild(h('div', { textContent: _t('Select an entry') }));
    panel.appendChild(ph);
  }

  function showTypeIcon(displayName, iconPos) {
    stopAnim();
    panel.innerHTML = '';
    const cfg = getTypeIconConfig();
    if (!cfg || iconPos == null) {
      const color = TYPE_COLORS[(displayName || '').toUpperCase()] || null;
      const ph = h('div', { className: 'pbs-preview-placeholder' });
      ph.appendChild(h('div', {
        style: {
          width: '80px', height: '28px', borderRadius: '4px',
          background: color ? color + '33' : 'var(--bg-tertiary)',
          border: '2px solid ' + (color || 'var(--border)'),
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          color: color || 'var(--text-tertiary)', fontWeight: '700', fontSize: '12px',
        },
        textContent: displayName || '?',
      }));
      panel.appendChild(ph);
      panel.appendChild(h('div', { className: 'pbs-preview-name', textContent: displayName || '' }));
      return;
    }
    const SCALE = Math.max(2, Math.floor(128 / cfg.iconW));
    const dispW = cfg.iconW * SCALE;
    const dispH = cfg.iconH * SCALE;
    const canvas = h('canvas', { width: dispW, height: dispH, style: { imageRendering: 'pixelated', borderRadius: '4px' } });
    const ctx2d = canvas.getContext('2d');
    ctx2d.imageSmoothingEnabled = false;
    const img = new Image();
    img.onload = () => {
      ctx2d.clearRect(0, 0, dispW, dispH);
      ctx2d.drawImage(img, 0, iconPos * cfg.iconH, cfg.iconW, cfg.iconH, 0, 0, dispW, dispH);
    };
    img.src = cfg.url;
    panel.appendChild(canvas);
    panel.appendChild(h('div', { className: 'pbs-preview-name', textContent: displayName || '' }));
  }

  return { el: panel, show, clear, showTypeIcon };
}

// ---- Sortable table ----
export function createTable(columns, rows, options = {}) {
  let sortCol = options.sortCol ?? 0;
  let sortDir = options.sortDir ?? 1;
  let selectedIdx = options.selectedIdx ?? -1;
  const table = h('table', { className: 'pbs-table' });
  const thead = h('thead');
  const tbody = h('tbody');
  table.appendChild(thead);
  table.appendChild(tbody);

  function renderHead() {
    thead.innerHTML = '';
    const tr = h('tr');
    for (let i = 0; i < columns.length; i++) {
      const col = columns[i];
      const th = h('th', { style: { width: (col.width || 80) + 'px' } });
      th.textContent = _t(col.label);
      if (i === sortCol) th.appendChild(h('span', { className: 'pbs-sort-arrow', textContent: sortDir === 1 ? '▲' : '▼' }));
      th.addEventListener('click', () => { if (sortCol === i) sortDir = -sortDir; else { sortCol = i; sortDir = 1; } render(); options.onSort?.(); });
      tr.appendChild(th);
    }
    thead.appendChild(tr);
  }

  function renderBody() {
    tbody.innerHTML = '';
    for (let i = 0; i < rows.length; i++) {
      const row = rows[i];
      const tr = h('tr', { className: `${i === selectedIdx ? 'selected' : ''} ${row._excluded ? 'excluded' : ''}` });
      for (const col of columns) {
        const val = row[col.key] ?? '';
        const td = h('td', { textContent: col.numeric ? (parseInt(val) || '') : String(val) });
        td.title = String(val);
        tr.appendChild(td);
      }
      tr.addEventListener('click', () => { selectedIdx = i; renderBody(); options.onSelect?.(i, row); });
      tr.addEventListener('contextmenu', (e) => { e.preventDefault(); selectedIdx = i; renderBody(); options.onContextMenu?.(e.clientX, e.clientY, i, row); });
      tbody.appendChild(tr);
    }
  }

  function render() { renderHead(); renderBody(); }
  function setSelected(idx) { selectedIdx = idx; renderBody(); }
  function getSortCol() { return sortCol; }
  function getSortDir() { return sortDir; }
  render();
  return { el: table, setSelected, render, getSelected: () => selectedIdx, getSortCol, getSortDir };
}

// ---- Collapsible section ----
export function createSectionToggle(label) {
  let open = true;
  const toggle = h('button', { className: 'pbs-section-toggle' });
  const arrow = h('span', { className: 'pbs-section-arrow open', textContent: '▶' });
  toggle.appendChild(arrow);
  toggle.appendChild(h('span', { textContent: _t(label) }));
  const body = h('div', { className: 'pbs-section-body', style: { display: 'block' } });
  toggle.addEventListener('click', () => { open = !open; arrow.className = `pbs-section-arrow ${open ? 'open' : ''}`; body.style.display = open ? 'block' : 'none'; });
  return { toggle, body };
}

// ---- GO TO button helper (module-level for reuse in sub-editors) ----
const GO_TO_SVG = "<svg xmlns='http://www.w3.org/2000/svg' x='0px' y='0px' viewBox='0 0 24 24' width='12' height='12' fill='currentColor'><path d='M 5 3 C 3.9069372 3 3 3.9069372 3 5 L 3 19 C 3 20.093063 3.9069372 21 5 21 L 19 21 C 20.093063 21 21 20.093063 21 19 L 21 12 L 19 12 L 19 19 L 5 19 L 5 5 L 12 5 L 12 3 L 5 3 z M 14 3 L 14 5 L 17.585938 5 L 8.2929688 14.292969 L 9.7070312 15.707031 L 19 6.4140625 L 19 10 L 21 10 L 21 3 L 14 3 z'></path></svg>";
function goToBtn(refKey, getValue, onNavigate) {
  if (!onNavigate || !refKey) return null;
  return h('button', { style: { background: 'transparent', border: 'none', color: 'var(--text-tertiary)', cursor: 'pointer', fontSize: '12px', padding: '0 2px', lineHeight: '1', flexShrink: '0', alignSelf: 'center', display: 'inline-flex', alignItems: 'center' }, innerHTML: GO_TO_SVG, onClick: (e) => { e.stopPropagation(); const v = getValue(); if (v) onNavigate(refKey, v); }, onMouseEnter: (e) => { e.target.style.color = 'var(--accent)'; }, onMouseLeave: (e) => { e.target.style.color = 'var(--text-tertiary)'; } });
}

// ---- Field editors ----
export function createFieldEditor(fieldDef, value, onChange, refData, ctx, onNavigate) {
  const wrap = h('div', { className: `pbs-field ${fieldDef.fullWidth ? 'full-width' : ''}` });
  wrap.appendChild(h('label', { textContent: _t(fieldDef.label) }));
  const type = fieldDef.type || 'text';

  // Get suggestions for reference fields
  const getSuggestions = (refKey) => {
    const ref = refKey || fieldDef.ref;
    if (!ref || !refData) return [];
    const entries = refData[ref];
    if (!entries) return [];
    return entries.map(e => e.InternalName || e.Name || '').filter(Boolean);
  };

  if (type === 'text' || type === 'number') {
    if (fieldDef.ref && type === 'text') {
      const row = h('div', { style: { display: 'flex', gap: '2px', alignItems: 'center' } });
      const ref = createRefInput(value, getSuggestions(), onChange);
      ref.el.style.flex = '1';
      ref.el.style.minWidth = '0';
      row.appendChild(ref.el);
      const btn = goToBtn(fieldDef.ref, () => ref.getValue(), onNavigate);
      if (btn) row.appendChild(btn);
      wrap.appendChild(row);
      return { el: wrap, getValue: () => ref.getValue(), setValue: (v) => ref.setValue(v) };
    }
    const input = h('input', { type: type === 'number' ? 'number' : 'text', value: String(value || ''), placeholder: fieldDef.placeholder || '' });
    if (fieldDef.min != null) input.min = fieldDef.min;
    if (fieldDef.max != null) input.max = fieldDef.max;
    if (fieldDef.step != null) input.step = fieldDef.step;
    input.addEventListener('input', () => onChange(input.value));
    wrap.appendChild(input);
    return { el: wrap, getValue: () => input.value, setValue: (v) => { input.value = v; } };
  }
  if (type === 'select') {
    const row = h('div', { style: { display: 'flex', gap: '2px', alignItems: 'center' } });
    const sel = h('select', { style: { flex: '1' } });
    sel.appendChild(h('option', { value: '', textContent: '—' }));
    for (const opt of (fieldDef.options || [])) sel.appendChild(h('option', { value: opt, textContent: opt, selected: opt === value }));
    if (value && !(fieldDef.options || []).includes(value)) {
      sel.appendChild(h('option', { value: value, textContent: value, selected: true }));
    }
    if (value) sel.value = value;
    sel.addEventListener('change', () => onChange(sel.value));
    row.appendChild(sel);
    const btn = goToBtn(fieldDef.ref, () => sel.value, onNavigate);
    if (btn) row.appendChild(btn);
    wrap.appendChild(row);
    return { el: wrap, getValue: () => sel.value, setValue: (v) => { sel.value = v; } };
  }
  if (type === 'checkbox') {
    const row = h('div', { style: { display: 'flex', alignItems: 'center', gap: '6px', paddingTop: '4px' } });
    const cb = h('input', { type: 'checkbox', checked: value === 'true' || value === true });
    cb.addEventListener('change', () => onChange(cb.checked ? 'true' : 'false'));
    row.appendChild(cb);
    const lbl = h('span', { textContent: value === 'true' ? _t('Yes') : _t('No'), style: { fontSize: '11px', color: 'var(--text-secondary)' } });
    cb.addEventListener('change', () => { lbl.textContent = cb.checked ? _t('Yes') : _t('No'); });
    row.appendChild(lbl);
    wrap.appendChild(row);
    return { el: wrap, getValue: () => cb.checked ? 'true' : 'false', setValue: (v) => { cb.checked = v === 'true'; } };
  }
  if (type === 'textarea') {
    const ta = h('textarea', { textContent: value || '' });
    ta.addEventListener('input', () => onChange(ta.value));
    wrap.appendChild(ta);
    return { el: wrap, getValue: () => ta.value, setValue: (v) => { ta.value = v; } };
  }
  if (type === 'list') {
    const items = (value || '').split(',').filter(Boolean);
    let typeIconPositions = null;
    if (fieldDef.ref === 'types' && refData?.types) {
      typeIconPositions = {};
      for (const t of refData.types) {
        const name = (t.InternalName || t.Name || '').toUpperCase();
        const pos = parseInt(t.IconPosition ?? t._id);
        if (name && !isNaN(pos)) typeIconPositions[name] = pos;
      }
    }
    const editor = createListEditor(items, onChange, fieldDef.ref ? getSuggestions() : null, onNavigate, fieldDef.ref, typeIconPositions);
    wrap.appendChild(editor.el);
    return { el: wrap, getValue: () => editor.getValue() };
  }
  if (type === 'pairs') {
    const rawItems = (value || '').split(',');
    const pairs = [];
    for (let i = 0; i < rawItems.length; i += 2) { if (rawItems[i] && rawItems[i + 1]) pairs.push([rawItems[i].trim(), rawItems[i + 1].trim()]); }
    const editor = createPairsEditor(pairs, fieldDef.pairLabels || ['A', 'B'], onChange, fieldDef.refB ? getSuggestions(fieldDef.refB) : null, onNavigate, fieldDef.refB);
    wrap.appendChild(editor.el);
    return { el: wrap, getValue: () => editor.getValue() };
  }
  if (type === 'triplets') {
    const rawItems = (value || '').split(',');
    const trips = [];
    for (let i = 0; i < rawItems.length; i += 3) { if (rawItems[i]) trips.push([rawItems[i]?.trim(), rawItems[i + 1]?.trim(), rawItems[i + 2]?.trim()]); }
    const editor = createTripletsEditor(trips, fieldDef.labels || ['A', 'B', 'C'], onChange, fieldDef.refA ? getSuggestions(fieldDef.refA) : null, onNavigate, fieldDef.refA, refData, !!fieldDef.evolution);
    wrap.appendChild(editor.el);
    return { el: wrap, getValue: () => editor.getValue() };
  }
  if (type === 'stats') {
    const parts = (value || '').split(',').map(n => parseInt(n.trim()) || 0);
    const statNames = fieldDef.statsKeys || ['HP', 'Atk', 'Def', 'Spe', 'SpAtk', 'SpDef'];
    const editor = createStatsEditor(parts, statNames, onChange);
    wrap.appendChild(editor.el);
    return { el: wrap, getValue: () => editor.getValue() };
  }
  if (type === 'evs') {
    const editor = createEvsEditor(value || '', onChange);
    wrap.appendChild(editor.el);
    return { el: wrap, getValue: () => editor.getValue() };
  }
  if (type === 'bgm') {
    const editor = createBgmEditor(value || '', onChange, ctx);
    wrap.appendChild(editor.el);
    return { el: wrap, getValue: () => editor.getValue() };
  }
  const input = h('input', { type: 'text', value: String(value || '') });
  input.addEventListener('input', () => onChange(input.value));
  wrap.appendChild(input);
  return { el: wrap, getValue: () => input.value, setValue: (v) => { input.value = v; } };
}

// ---- List editor ----
function createListEditor(items, onChange, suggestions, onNavigate, refKey, typeIconPositions) {
  const container = h('div', { className: 'pbs-list-editor' });
  const isTypeField = refKey === 'types';

  function getIconPos(typeName) {
    if (!isTypeField || !typeIconPositions) return null;
    const pos = typeIconPositions[(typeName || '').toUpperCase()];
    return pos !== undefined ? pos : null;
  }

  function render() {
    container.innerHTML = '';
    for (let i = 0; i < items.length; i++) {
      const row = h('div', { className: 'pbs-list-row' });

      let indicator = null;
      if (isTypeField) {
        indicator = makeTypeIndicator(items[i], getIconPos(items[i]));
        row.appendChild(indicator);
      }

      if (suggestions) {
        const ii = i;
        const ref = createRefInput(items[i], suggestions, (v) => {
          items[ii] = v;
          if (indicator) updateTypeIndicator(indicator, v, getIconPos(v));
          emitChange();
        });
        ref.el.style.flex = '1';
        ref.el.style.minWidth = '0';
        row.appendChild(ref.el);
      } else {
        const inp = h('input', { value: items[i] });
        inp.addEventListener('input', () => { items[i] = inp.value; emitChange(); });
        row.appendChild(inp);
      }
      const gBtn = goToBtn(refKey, () => items[i], onNavigate);
      if (gBtn) row.appendChild(gBtn);
      row.appendChild(h('button', { className: 'pbs-list-remove', textContent: '×', onClick: () => { items.splice(i, 1); render(); emitChange(); } }));
      container.appendChild(row);
    }
    container.appendChild(h('button', { className: 'pbs-list-add', textContent: _t('+ Add'), onClick: () => { items.push(''); render(); } }));
  }
  function emitChange() { onChange(items.filter(Boolean).join(',')); }
  render();
  return { el: container, getValue: () => items.filter(Boolean).join(',') };
}

// ---- Pairs editor ----
function createPairsEditor(pairs, labels, onChange, suggestions, onNavigate, refKey) {
  const container = h('div', { className: 'pbs-list-editor' });
  function render() {
    container.innerHTML = '';
    for (let i = 0; i < pairs.length; i++) {
      const row = h('div', { className: 'pbs-list-row' });
      // First column (always plain input)
      const inp0 = h('input', { value: pairs[i][0], placeholder: _t(labels[0]), style: { width: '40px', flex: 'none' } });
      const ii0 = i;
      inp0.addEventListener('input', () => { pairs[ii0][0] = inp0.value; emitChange(); });
      row.appendChild(inp0);
      // Second column (with suggestions if provided)
      if (suggestions) {
        const ref = createRefInput(pairs[i][1], suggestions, (v) => { pairs[ii0][1] = v; emitChange(); });
        ref.el.style.flex = '1';
        ref.el.style.minWidth = '0';
        row.appendChild(ref.el);
      } else {
        const inp1 = h('input', { value: pairs[i][1], placeholder: _t(labels[1]) });
        const ii1 = i;
        inp1.addEventListener('input', () => { pairs[ii1][1] = inp1.value; emitChange(); });
        row.appendChild(inp1);
      }
      const pBtn = goToBtn(refKey, () => pairs[i]?.[1] || '', onNavigate);
      if (pBtn) row.appendChild(pBtn);
      row.appendChild(h('button', { className: 'pbs-list-remove', textContent: '×', onClick: () => { pairs.splice(i, 1); render(); emitChange(); } }));
      container.appendChild(row);
    }
    container.appendChild(h('button', { className: 'pbs-list-add', textContent: _t('+ Add'), onClick: () => { pairs.push(['', '']); render(); } }));
  }
  function emitChange() { onChange(pairs.map(p => `${p[0]},${p[1]}`).join(',')); }
  render();
  return { el: container, getValue: () => pairs.map(p => `${p[0]},${p[1]}`).join(',') };
}

// ---- Triplets editor ----
// Build an uppercase internal-name set for a file type (items / pokemon / moves / types).
function pbsNameSet(refData, key) {
  const set = new Set();
  const list = refData && Array.isArray(refData[key]) ? refData[key] : [];
  for (const e of list) {
    const n = (e.InternalName || e.Name || '').toUpperCase();
    if (n) set.add(n);
  }
  return set;
}

// Infer, from how each evolution method is actually used in the loaded PBS
// data, what KIND of value its parameter takes (item / pokemon / move / type).
// No hardcoded method list: a method is classified by majority vote of its
// observed parameters against the project's own name sets. Methods whose
// parameters are numbers or unrecognized get no autocomplete (free text).
function buildEvoParamKinds(refData) {
  const sets = {
    items: pbsNameSet(refData, 'items'),
    pokemon: pbsNameSet(refData, 'pokemon'),
    moves: pbsNameSet(refData, 'moves'),
    types: pbsNameSet(refData, 'types'),
  };
  const paramsByMethod = new Map();
  const collect = (raw) => {
    if (!raw) return;
    const toks = raw.split(',');
    for (let i = 1; i + 1 < toks.length; i += 3) {
      const method = (toks[i] || '').trim();
      if (!method) continue;
      const param = (toks[i + 1] || '').trim();
      if (!param) continue;
      if (!paramsByMethod.has(method)) paramsByMethod.set(method, []);
      paramsByMethod.get(method).push(param);
    }
  };
  for (const key of ['pokemon', 'pokemon_forms']) {
    const list = refData && refData[key];
    if (Array.isArray(list)) for (const e of list) collect(e.Evolutions || e.Evolution || '');
  }
  const kindFor = new Map();
  for (const [method, params] of paramsByMethod) {
    const votes = { items: 0, pokemon: 0, moves: 0, types: 0 };
    for (const p of params) {
      const up = p.toUpperCase();
      if (sets.items.has(up)) votes.items++;
      else if (sets.pokemon.has(up)) votes.pokemon++;
      else if (sets.moves.has(up)) votes.moves++;
      else if (sets.types.has(up)) votes.types++;
    }
    let best = null, bestN = 0, total = 0;
    for (const k of ['items', 'pokemon', 'moves', 'types']) {
      total += votes[k];
      if (votes[k] > bestN) { bestN = votes[k]; best = k; }
    }
    if (best && total > 0 && bestN * 2 >= total) kindFor.set(method, best);
  }
  return kindFor;
}

// Names to suggest for a given method's parameter (empty array → free text).
function evoParamNames(refData, method, kindMap) {
  const kind = kindMap && kindMap.get(method);
  if (!kind) return [];
  return (refData && Array.isArray(refData[kind]) ? refData[kind] : [])
    .map(e => e.InternalName || e.Name || '').filter(Boolean);
}

// Scan every Evolutions line in the loaded PBS data and collect the distinct
// method names actually in use. This is the source of truth (not a hardcoded
// list), so methods added by custom bases show up automatically.
function collectEvolutionMethods(refData) {
  const set = new Set();
  for (const key of ['pokemon', 'pokemon_forms']) {
    const list = refData && refData[key];
    if (!Array.isArray(list)) continue;
    for (const e of list) {
      const raw = e.Evolutions || e.Evolution || '';
      if (!raw) continue;
      const toks = raw.split(',');
      for (let i = 1; i < toks.length; i += 3) {
        const m = (toks[i] || '').trim();
        if (m) set.add(m);
      }
    }
  }
  return [...set].sort();
}

function createTripletsEditor(trips, labels, onChange, suggestions, onNavigate, refKey, refData, isEvolution) {
  const container = h('div', { className: 'pbs-list-editor' });
  const cell = (t, idx) => (t[idx] == null ? '' : t[idx]);
  const methodList = isEvolution ? collectEvolutionMethods(refData) : [];
  const paramKindMap = isEvolution ? buildEvoParamKinds(refData) : null;
  function render() {
    container.innerHTML = '';
    for (let i = 0; i < trips.length; i++) {
      const row = h('div', { className: 'pbs-list-row' });
      const ii = i;
      // Column 0: Target (species autocomplete if provided)
      if (suggestions) {
        const ref = createRefInput(cell(trips[i], 0), suggestions, (v) => { trips[i][0] = v; emitChange(); }, _t(labels[0]));
        ref.el.style.width = '70px';
        ref.el.style.flex = 'none';
        row.appendChild(ref.el);
      } else {
        const inp = h('input', { value: cell(trips[i], 0), placeholder: _t(labels[0]), style: { width: '70px', flex: 'none' } });
        inp.addEventListener('input', () => { trips[ii][0] = inp.value; emitChange(); });
        row.appendChild(inp);
      }
      // Column 1: Method — free-text combo backed by the methods seen in the
      // data, so a brand-new method can also be typed in.
      const methodRef = createRefInput(cell(trips[i], 1), methodList, (v) => { trips[ii][1] = v; emitChange(); }, _t(labels[1]));
      methodRef.el.style.width = '92px';
      methodRef.el.style.flex = 'none';
      row.appendChild(methodRef.el);
      // Column 2: Param — autocomplete kind follows the currently entered method.
      const paramSrc = isEvolution ? () => evoParamNames(refData, cell(trips[ii], 1), paramKindMap) : [];
      const paramRef = createRefInput(cell(trips[i], 2), paramSrc, (v) => { trips[ii][2] = v; emitChange(); }, _t(labels[2]));
      paramRef.el.style.flex = '1';
      paramRef.el.style.minWidth = '0';
      row.appendChild(paramRef.el);
      const tBtn = goToBtn(refKey, () => cell(trips[i], 0), onNavigate);
      if (tBtn) row.appendChild(tBtn);
      row.appendChild(h('button', { className: 'pbs-list-remove', textContent: '×', onClick: () => { trips.splice(i, 1); render(); emitChange(); } }));
      container.appendChild(row);
    }
    container.appendChild(h('button', { className: 'pbs-list-add', textContent: _t('+ Add'), onClick: () => { trips.push(['', '', '']); render(); } }));
  }
  // Coerce missing cells to '' so an unset param never serializes as the
  // literal string "undefined", and drop rows whose target species is empty.
  const serialize = () => trips.filter(t => cell(t, 0)).map(t => `${cell(t, 0)},${cell(t, 1)},${cell(t, 2)}`).join(',');
  function emitChange() { onChange(serialize()); }
  render();
  return { el: container, getValue: serialize };
}

// ---- Stats editor ----
function statColor(val) {
  if (val <= 30) return '#ff6b6b';
  if (val <= 60) return '#fbbf24';
  if (val <= 90) return '#4ade80';
  return '#7c8aff';
}
function createStatsEditor(values, names, onChange) {
  const container = h('div', {});
  let _bstFill = null;
  let _bstVal = null;

  function calcBst() { return values.reduce((s, v) => s + (v || 0), 0); }
  function updateBst() {
    const bst = calcBst();
    if (_bstFill) _bstFill.style.width = Math.min(100, bst / 7.2) + '%';
    if (_bstVal) _bstVal.textContent = String(bst);
  }

  function render() {
    container.innerHTML = '';
    for (let i = 0; i < names.length; i++) {
      const row = h('div', { className: 'pbs-stat-row' });
      row.appendChild(h('span', { className: 'pbs-stat-label', textContent: names[i] }));
      const barBg = h('div', { className: 'pbs-stat-bar-bg' });
      const fill = h('div', { className: 'pbs-stat-bar-fill', style: { width: Math.min(100, (values[i] || 0) / 2.55) + '%', background: statColor(values[i] || 0) } });
      barBg.appendChild(fill);
      row.appendChild(barBg);
      const inp = h('input', { type: 'number', className: 'pbs-stat-value', value: values[i] || 0, min: 0, max: 255 });
      const ii = i;
      inp.addEventListener('input', () => { values[ii] = parseInt(inp.value) || 0; fill.style.width = Math.min(100, values[ii] / 2.55) + '%'; fill.style.background = statColor(values[ii]); updateBst(); emitChange(); });
      row.appendChild(inp);
      container.appendChild(row);
    }

    // BST row
    const bst = calcBst();
    const bstRow = h('div', { className: 'pbs-stat-row pbs-stat-bst-row' });
    bstRow.appendChild(h('span', { className: 'pbs-stat-label', textContent: 'BST' }));
    const bstBarBg = h('div', { className: 'pbs-stat-bar-bg' });
    _bstFill = h('div', { className: 'pbs-stat-bar-fill', style: { width: Math.min(100, bst / 7.2) + '%', background: '#7c8aff' } });
    bstBarBg.appendChild(_bstFill);
    bstRow.appendChild(bstBarBg);
    _bstVal = h('span', { className: 'pbs-stat-value', textContent: String(bst) });
    bstRow.appendChild(_bstVal);
    container.appendChild(bstRow);
  }
  function emitChange() { onChange(values.join(',')); }
  render();
  return { el: container, getValue: () => values.join(',') };
}

// ---- EVs editor ----
const EV_STAT_MAP = [
  { key: 'HP', display: 'HP' },
  { key: 'ATTACK', display: 'Atk' },
  { key: 'DEFENSE', display: 'Def' },
  { key: 'SPEED', display: 'Spe' },
  { key: 'SPECIAL_ATTACK', display: 'SpAtk' },
  { key: 'SPECIAL_DEFENSE', display: 'SpDef' },
];
function createEvsEditor(value, onChange) {
  const container = h('div', { className: 'pbs-list-editor' });
  const pairs = [];
  const parts = (value || '').split(',');
  for (let i = 0; i < parts.length; i += 2) {
    const stat = (parts[i] || '').trim();
    const val = parseInt((parts[i + 1] || '').trim()) || 0;
    if (stat) pairs.push({ stat, val });
  }

  function emitChange() {
    onChange(pairs.map(p => `${p.stat},${p.val}`).join(','));
  }

  function render() {
    container.innerHTML = '';
    for (let i = 0; i < pairs.length; i++) {
      const row = h('div', { className: 'pbs-list-row' });
      const statInput = h('select', { style: { flex: '1' } });
      for (const s of EV_STAT_MAP) {
        statInput.appendChild(h('option', { value: s.key, textContent: s.display, selected: s.key === pairs[i].stat }));
      }
      if (!EV_STAT_MAP.some(s => s.key === pairs[i].stat)) {
        statInput.appendChild(h('option', { value: pairs[i].stat, textContent: pairs[i].stat, selected: true }));
      }
      const ii = i;
      statInput.addEventListener('change', () => { pairs[ii].stat = statInput.value; emitChange(); });
      row.appendChild(statInput);

      const numInput = h('input', { type: 'number', value: pairs[i].val, min: 0, max: 255, style: { width: '55px' } });
      numInput.addEventListener('input', () => { pairs[ii].val = parseInt(numInput.value) || 0; emitChange(); });
      row.appendChild(numInput);

      row.appendChild(h('button', { className: 'pbs-list-remove', textContent: '×', onClick: () => { pairs.splice(i, 1); render(); emitChange(); } }));
      container.appendChild(row);
    }
    container.appendChild(h('button', { className: 'pbs-list-add', textContent: _t('+ Add EV'), onClick: () => { pairs.push({ stat: 'HP', val: 0 }); render(); emitChange(); } }));
  }
  render();
  return { el: container, getValue: () => pairs.map(p => `${p.stat},${p.val}`).join(',') };
}

// ---- BGM editor ----
function createBgmEditor(value, onChange, ctx) {
  const row = h('div', { className: 'pbs-list-row' });
  const input = h('input', { type: 'text', value: String(value || ''), placeholder: 'Audio/BGM/filename', style: { flex: '1' } });
  input.addEventListener('input', () => onChange(input.value));
  row.appendChild(input);

  if (ctx?.selectors?.pickAudio) {
    const browseBtn = h('button', { className: 'pbs-btn', textContent: _t('Browse'), onClick: async () => {
      try {
        const result = await ctx.selectors.pickAudio('BGM');
        if (result) {
          const val = typeof result === 'string' ? result : (result.path || result.name || String(result));
          input.value = val;
          onChange(val);
        }
      } catch {}
    } });
    row.appendChild(browseBtn);
  }
  return { el: row, getValue: () => input.value };
}

// ---- Encounter sub-section editor ----
const ENCOUNTER_TYPES = ['Land', 'LandDay', 'LandNight', 'LandMorning', 'Cave', 'Water', 'None'];

export function createEncounterEditor(entry, onChange, onRebuild, refData, onNavigate) {
  const container = h('div', {});
  const pokemonSuggestions = refData?.pokemon?.map(e => e.InternalName || e.Name || '').filter(Boolean) || [];

  function buildEncounter(ei, enc) {
    const sub = h('div', { className: 'pbs-subsection' });

    // Header with type dropdown, density, and delete
    const header = h('div', { className: 'pbs-subsection-header' });
    const typeSelect = h('select', { style: { fontSize: '11px', background: 'var(--input-bg)', color: 'var(--text-primary)', border: '1px solid var(--border)', borderRadius: '3px', padding: '1px 4px' } });
    for (const t of ENCOUNTER_TYPES) {
      typeSelect.appendChild(h('option', { value: t, textContent: t, selected: t === enc.type }));
    }
    typeSelect.addEventListener('change', () => { enc.type = typeSelect.value; onChange(); });
    header.appendChild(typeSelect);

    header.appendChild(h('span', { textContent: _t('Density:'), style: { fontSize: '10px', color: 'var(--text-tertiary)', marginLeft: '6px' } }));
    const densityInp = h('input', { type: 'number', value: enc.density || '20', min: 1, max: 999, style: { width: '40px', fontSize: '11px', padding: '1px 4px', background: 'var(--input-bg)', color: 'var(--text-primary)', border: '1px solid var(--border)', borderRadius: '3px' } });
    densityInp.addEventListener('input', () => { enc.density = densityInp.value; onChange(); });
    header.appendChild(densityInp);

    header.appendChild(h('div', { style: { flex: '1' } }));
    header.appendChild(h('button', { className: 'pbs-list-remove', textContent: '×', onClick: () => { entry._encounters.splice(ei, 1); onChange(); onRebuild(); } }));
    sub.appendChild(header);

    const body = h('div', { className: 'pbs-subsection-body' });

    // Column header: Prob, Pokemon, Min Lv, Max Lv
    const colHeader = h('div', { className: 'pbs-list-row', style: { fontWeight: '600', fontSize: '10px', color: 'var(--text-tertiary)' } });
    colHeader.appendChild(h('span', { style: { width: '30px', flexShrink: '0' }, textContent: '#' }));
    colHeader.appendChild(h('span', { style: { width: '45px' }, textContent: 'Prob' }));
    colHeader.appendChild(h('span', { style: { flex: '1' }, textContent: _t('Pokemon') }));
    colHeader.appendChild(h('span', { style: { width: '45px' }, textContent: _t('Min Lv') }));
    colHeader.appendChild(h('span', { style: { width: '45px' }, textContent: _t('Max Lv') }));
    colHeader.appendChild(h('span', { style: { width: '20px' } }));
    body.appendChild(colHeader);

    function buildPokemonRows() {
      while (body.children.length > 1) body.removeChild(body.lastChild);

      for (let pi = 0; pi < enc.pokemons.length; pi++) {
        const rawParts = (enc.pokemons[pi] || '').split(',');
        // Format: PROBABILITY,SPECIES,MIN_LV,MAX_LV
        const prob = (rawParts[0] || '').trim();
        const species = (rawParts[1] || '').trim();
        const minLv = (rawParts[2] || '').trim();
        const maxLv = (rawParts[3] || '').trim();

        const row = h('div', { className: 'pbs-list-row' });
        row.appendChild(h('span', { style: { width: '30px', flexShrink: '0', fontSize: '10px', color: 'var(--text-tertiary)' }, textContent: String(pi + 1) }));

        // Probability
        const probInp = h('input', { type: 'number', value: prob, min: 0, max: 100, placeholder: '%', style: { width: '35px', fontFamily: 'inherit', fontSize: '12px', padding: '3px 6px' } });
        probInp.addEventListener('input', () => { rawParts[0] = probInp.value; enc.pokemons[pi] = rawParts.join(','); onChange(); });
        row.appendChild(probInp);

        // Species with reference autocomplete
        const speciesRef = createRefInput(species, pokemonSuggestions, (v) => {
          rawParts[1] = v;
          enc.pokemons[pi] = rawParts.join(',');
          onChange();
        });
        speciesRef.el.style.flex = '2';
        speciesRef.el.style.minWidth = '80px';
        row.appendChild(speciesRef.el);
        const speciesBtn = goToBtn('pokemon', () => species, onNavigate);
        if (speciesBtn) row.appendChild(speciesBtn);

        // Min level
        const minInp = h('input', { type: 'number', value: minLv, min: 1, max: 100, placeholder: 'Min', style: { width: '35px', fontFamily: 'inherit', fontSize: '12px', padding: '3px 6px' } });
        minInp.addEventListener('input', () => { rawParts[2] = minInp.value; enc.pokemons[pi] = rawParts.join(','); onChange(); });
        row.appendChild(minInp);

        // Max level
        const maxInp = h('input', { type: 'number', value: maxLv, min: 1, max: 100, placeholder: 'Max', style: { width: '35px', fontFamily: 'inherit', fontSize: '12px', padding: '3px 6px' } });
        maxInp.addEventListener('input', () => { rawParts[3] = maxInp.value; enc.pokemons[pi] = rawParts.join(','); onChange(); });
        row.appendChild(maxInp);

        row.appendChild(h('button', { className: 'pbs-list-remove', textContent: '×', onClick: () => { enc.pokemons.splice(pi, 1); onChange(); buildPokemonRows(); } }));
        body.appendChild(row);
      }

      body.appendChild(h('button', { className: 'pbs-list-add', textContent: _t('+ Add Pokemon'), onClick: () => {
        enc.pokemons.push('20,SPECIES,5,5');
        onChange();
        buildPokemonRows();
      } }));
    }

    buildPokemonRows();
    sub.appendChild(body);
    return sub;
  }

  function renderAll() {
    container.innerHTML = '';
    for (let ei = 0; ei < (entry._encounters || []).length; ei++) {
      container.appendChild(buildEncounter(ei, entry._encounters[ei]));
    }
    container.appendChild(h('button', { className: 'pbs-list-add', textContent: _t('+ Add Encounter Type'), style: { marginTop: '4px' }, onClick: () => {
      entry._encounters.push({ type: 'Land', density: '20', pokemons: [] });
      onChange();
      renderAll();
    } }));
  }
  renderAll();
  return container;
}

// ---- Trainer pokemon editor ----
export function createTrainerPokemonEditor(entry, onChange, onRebuild, refData, ctx, onNavigate) {
  const container = h('div', {});
  const pokemonSuggestions = refData?.pokemon?.map(e => e.InternalName || e.Name || '').filter(Boolean) || [];
  const moveSuggestions = refData?.moves?.map(e => e.InternalName || e.Name || '').filter(Boolean) || [];
  const itemSuggestions = refData?.items?.map(e => e.InternalName || e.Name || '').filter(Boolean) || [];

  function renderAll() {
    container.innerHTML = '';
    for (let pi = 0; pi < (entry._pokemon || []).length; pi++) {
      const p = entry._pokemon[pi];
      const sub = h('div', { className: 'pbs-subsection' });
      const header = h('div', { className: 'pbs-subsection-header' });
      header.appendChild(h('span', { textContent: _t('Pokemon {n}', { n: pi + 1 }) }));
      header.appendChild(h('button', { className: 'pbs-list-remove', textContent: '×', onClick: () => { entry._pokemon.splice(pi, 1); onRebuild(); } }));
      sub.appendChild(header);
      const body = h('div', { className: 'pbs-subsection-body', style: { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '4px 8px' } });

      // Parse Pokemon field: SPECIES,LEVEL
      const pokeParts = (p.Pokemon || '').split(',');
      const species = (pokeParts[0] || '').trim();
      const level = (pokeParts[1] || '').trim();

      // Species
      const speciesField = h('div', { className: 'pbs-field' });
      speciesField.appendChild(h('label', { textContent: _t('Species') }));
      const speciesRow = h('div', { style: { display: 'flex', gap: '2px', alignItems: 'center' } });
      const speciesRef = createRefInput(species, pokemonSuggestions, (v) => {
        pokeParts[0] = v;
        p.Pokemon = pokeParts.filter(Boolean).join(',');
        onChange();
      });
      speciesRef.el.style.flex = '1';
      speciesRef.el.style.minWidth = '0';
      speciesRow.appendChild(speciesRef.el);
      const speciesBtn = goToBtn('pokemon', () => species, onNavigate);
      if (speciesBtn) speciesRow.appendChild(speciesBtn);
      speciesField.appendChild(speciesRow);
      body.appendChild(speciesField);

      // Level
      const levelField = h('div', { className: 'pbs-field' });
      levelField.appendChild(h('label', { textContent: _t('Level') }));
      const levelInp = h('input', { type: 'number', value: level, min: 1, max: 100, placeholder: 'Level' });
      levelInp.addEventListener('input', () => {
        pokeParts[1] = levelInp.value;
        p.Pokemon = pokeParts.filter(Boolean).join(',');
        onChange();
      });
      levelField.appendChild(levelInp);
      body.appendChild(levelField);

      // Item (referenced)
      const itemField = h('div', { className: 'pbs-field' });
      itemField.appendChild(h('label', { textContent: _t('Item') }));
      const itemRow = h('div', { style: { display: 'flex', gap: '2px', alignItems: 'center' } });
      const itemRef = createRefInput(p.Item || '', itemSuggestions, (v) => { p.Item = v; onChange(); });
      itemRef.el.style.flex = '1';
      itemRef.el.style.minWidth = '0';
      itemRow.appendChild(itemRef.el);
      const itemBtn = goToBtn('items', () => p.Item || '', onNavigate);
      if (itemBtn) itemRow.appendChild(itemBtn);
      itemField.appendChild(itemRow);
      body.appendChild(itemField);

      // AbilityIndex
      const abilityField = h('div', { className: 'pbs-field' });
      abilityField.appendChild(h('label', { textContent: _t('Ability Index') }));
      const abilityInp = h('input', { type: 'number', value: p.AbilityIndex || '', min: 0, placeholder: '0' });
      abilityInp.addEventListener('input', () => { p.AbilityIndex = abilityInp.value; onChange(); });
      abilityField.appendChild(abilityInp);
      body.appendChild(abilityField);

      // Moves (list with move references)
      const movesField = h('div', { className: 'pbs-field', style: { gridColumn: '1 / -1' } });
      movesField.appendChild(h('label', { textContent: _t('Moves') }));
      const movesItems = (p.Moves || '').split(',').filter(Boolean);
      const movesEditor = createListEditor(movesItems, (v) => { p.Moves = v; onChange(); }, moveSuggestions, onNavigate, 'moves');
      movesField.appendChild(movesEditor.el);
      body.appendChild(movesField);

      // Nature
      const natureField = h('div', { className: 'pbs-field' });
      natureField.appendChild(h('label', { textContent: _t('Nature') }));
      const natureInp = h('input', { type: 'text', value: p.Nature || '', placeholder: 'Nature' });
      natureInp.addEventListener('input', () => { p.Nature = natureInp.value; onChange(); });
      natureField.appendChild(natureInp);
      body.appendChild(natureField);

      // Gender
      const genderField = h('div', { className: 'pbs-field' });
      genderField.appendChild(h('label', { textContent: _t('Gender') }));
      const genderInp = h('input', { type: 'text', value: p.Gender || '', placeholder: 'M/F' });
      genderInp.addEventListener('input', () => { p.Gender = genderInp.value; onChange(); });
      genderField.appendChild(genderInp);
      body.appendChild(genderField);

      // Form
      const formField = h('div', { className: 'pbs-field' });
      formField.appendChild(h('label', { textContent: _t('Form') }));
      const formInp = h('input', { type: 'number', value: p.Form || '', min: 0, placeholder: '0' });
      formInp.addEventListener('input', () => { p.Form = formInp.value; onChange(); });
      formField.appendChild(formInp);
      body.appendChild(formField);

      // Shiny
      const shinyField = h('div', { className: 'pbs-field' });
      shinyField.appendChild(h('label', { textContent: _t('Shiny') }));
      const shinyRow = h('div', { style: { display: 'flex', alignItems: 'center', gap: '4px' } });
      const shinyCb = h('input', { type: 'checkbox', checked: p.Shiny === 'true' || p.Shiny === true });
      const shinyLbl = h('span', { textContent: p.Shiny === 'true' ? _t('Yes') : _t('No'), style: { fontSize: '11px', color: 'var(--text-secondary)' } });
      shinyCb.addEventListener('change', () => { p.Shiny = shinyCb.checked ? 'true' : 'false'; shinyLbl.textContent = shinyCb.checked ? _t('Yes') : _t('No'); onChange(); });
      shinyRow.appendChild(shinyCb);
      shinyRow.appendChild(shinyLbl);
      shinyField.appendChild(shinyRow);
      body.appendChild(shinyField);

      // IV (full width, structured like EVs)
      const ivField = h('div', { className: 'pbs-field', style: { gridColumn: '1 / -1' } });
      ivField.appendChild(h('label', { textContent: _t('IVs') }));
      const ivEditor = createEvsEditor(p.IV || '', (v) => { p.IV = v; onChange(); });
      ivField.appendChild(ivEditor.el);
      body.appendChild(ivField);

      // EV (full width)
      const evField = h('div', { className: 'pbs-field', style: { gridColumn: '1 / -1' } });
      evField.appendChild(h('label', { textContent: _t('EVs') }));
      const evEditor = createEvsEditor(p.EV || '', (v) => { p.EV = v; onChange(); });
      evField.appendChild(evEditor.el);
      body.appendChild(evField);

      sub.appendChild(body);
      container.appendChild(sub);
    }
    container.appendChild(h('button', { className: 'pbs-list-add', textContent: _t('+ Add Pokemon'), style: { marginTop: '4px' }, onClick: () => { entry._pokemon.push({ Pokemon: '' }); onRebuild(); } }));
  }
  renderAll();
  return container;
}

// ---- Context menu ----
let activeCtxMenu = null;
export function showContextMenu(x, y, items, host) {
  closeContextMenu();
  const menu = h('div', { className: 'pbs-ctx-menu', style: { left: x + 'px', top: y + 'px' } });
  for (const item of items) {
    if (item.separator) { menu.appendChild(h('div', { className: 'pbs-ctx-sep' })); continue; }
    menu.appendChild(h('button', { className: `pbs-ctx-item ${item.danger ? 'danger' : ''}`, textContent: item.label, onClick: (e) => { e.stopPropagation(); closeContextMenu(); item.action?.(); } }));
  }
  host.appendChild(menu);
  activeCtxMenu = menu;
  const close = (e) => { if (!menu.contains(e.target)) closeContextMenu(); };
  document.addEventListener('mousedown', close, true);
  menu._cleanup = () => document.removeEventListener('mousedown', close, true);
}
function closeContextMenu() { if (activeCtxMenu) { activeCtxMenu._cleanup?.(); activeCtxMenu.remove(); activeCtxMenu = null; } }

// ---- Reference autocomplete ----
// Shows suggestions from loaded PBS entries while typing.

export function createRefInput(value, suggestions, onChange, placeholder) {
  const wrap = h('div', { style: { position: 'relative' } });
  const input = h('input', {
    type: 'text',
    value: String(value || ''),
    style: { width: '100%' },
  });
  if (placeholder) input.placeholder = placeholder;
  input.style.cssText += ';padding:3px 6px;border:1px solid var(--border);border-radius:3px;background:var(--input-bg);color:var(--text-primary);font-size:12px;font-family:inherit;outline:none;width:100%;';
  input.addEventListener('focus', () => input.focus?.());
  // `suggestions` may be a static array or a function returning the current
  // list (the evolution Param list depends on the selected Method).
  const getList = () => (typeof suggestions === 'function' ? (suggestions() || []) : (suggestions || []));

  const dropdown = h('div', {
    className: 'pbs-ref-dropdown',
    style: { display: 'none' },
  });

  let activeIdx = -1;
  let filtered = [];

  function filterItems(q) {
    const list = getList();
    if (!list.length) { filtered = []; return; }
    if (!q) { filtered = list.filter(s => typeof s === 'string').slice(0, 20); return; }
    const lower = q.toLowerCase();
    filtered = list.filter(s => typeof s === 'string' && s.toLowerCase().includes(lower)).slice(0, 20);
  }

  function renderDropdown() {
    dropdown.innerHTML = '';
    if (!filtered.length) { dropdown.style.display = 'none'; activeIdx = -1; return; }
    dropdown.style.display = 'block';
    filtered.forEach((item, i) => {
      const opt = h('div', { className: `pbs-ref-item ${i === activeIdx ? 'active' : ''}`, textContent: item });
      opt.addEventListener('mousedown', (e) => {
        e.preventDefault();
        input.value = item;
        dropdown.style.display = 'none';
        onChange(item);
      });
      dropdown.appendChild(opt);
    });
  }

  input.addEventListener('input', () => {
    const q = input.value.trim();
    filterItems(q);
    activeIdx = -1;
    renderDropdown();
    onChange(input.value);
  });

  input.addEventListener('focus', () => {
    filterItems(input.value.trim());
    renderDropdown();
  });

  input.addEventListener('blur', () => { setTimeout(() => { dropdown.style.display = 'none'; }, 150); });

  input.addEventListener('keydown', (e) => {
    if (dropdown.style.display === 'none' || !filtered.length) return;
    if (e.key === 'ArrowDown') { e.preventDefault(); activeIdx = Math.min(activeIdx + 1, filtered.length - 1); renderDropdown(); }
    else if (e.key === 'ArrowUp') { e.preventDefault(); activeIdx = Math.max(activeIdx - 1, 0); renderDropdown(); }
    else if (e.key === 'Enter' || e.key === 'Tab') {
      if (activeIdx >= 0 && activeIdx < filtered.length) {
        e.preventDefault();
        input.value = filtered[activeIdx];
        dropdown.style.display = 'none';
        onChange(input.value);
      }
    } else if (e.key === 'Escape') { dropdown.style.display = 'none'; }
  });

  wrap.appendChild(input);
  wrap.appendChild(dropdown);
  return { el: wrap, getValue: () => input.value, setValue: (v) => { input.value = v; } };
}
