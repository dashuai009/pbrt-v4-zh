(() => {
  const enhance = () => {
    document.querySelectorAll('main pre').forEach(pre => {
      if (pre.dataset.copyReady) return;
      pre.dataset.copyReady = 'true';
      const button = document.createElement('button');
      button.className = 'copy-code'; button.type = 'button'; button.textContent = '复制代码';
      button.addEventListener('click', async () => {
        try { await navigator.clipboard.writeText((pre.querySelector('code') || pre).textContent); button.textContent = '已复制'; }
        catch { button.textContent = '请选中代码复制'; }
      });
      pre.before(button);
    });
  };
  enhance(); new MutationObserver(enhance).observe(document.querySelector('main') || document.body,{childList:true,subtree:true});
})();
(() => {
  const input = document.getElementById('searchbar');
  const toggle = document.getElementById('search-toggle');
  const wrapper = document.getElementById('search-wrapper');
  const outer = document.getElementById('searchresults-outer');
  const results = document.getElementById('searchresults');
  const header = document.getElementById('searchresults-header');
  if (!input || !toggle || !results) return;
  input.placeholder = '搜索中文、英文或代码';
  input.setAttribute('aria-label','搜索全书');
  window.search = {hasFocus: () => document.activeElement === input};
  const script = document.querySelector('script[src$="theme/reader.js"]');
  const root = new URL('../', script.src);
  let dataPromise, generation = 0;
  const search = async () => {
    const turn = ++generation, query = input.value.trim().toLocaleLowerCase();
    results.replaceChildren(); outer.classList.remove('hidden');
    if (!query) { header.textContent = '输入关键词，可搜索完整正文。'; return; }
    header.textContent = '正在搜索…';
    try {
      const data = await (dataPromise ||= fetch(new URL('reader-search.json',root)).then(r => {if(!r.ok)throw Error('index');return r.json();}));
      if (turn !== generation) return;
      const terms = query.split(/\s+/), lang = location.pathname.includes('/zh-en/') ? 'zh-en' : 'zh';
      const matches = data.filter(p => terms.every(t => (p.title+' '+p.body).toLocaleLowerCase().includes(t))).sort((a,b) => (b.lang===lang)-(a.lang===lang) || Number(b.title.toLocaleLowerCase().includes(query))-Number(a.title.toLocaleLowerCase().includes(query)));
      header.textContent = matches.length ? `找到 ${matches.length} 个页面（显示前 50 项）` : `没有找到“${input.value.trim()}”`;
      for (const p of matches.slice(0,50)) {
        const li=document.createElement('li'), a=document.createElement('a'), snippet=document.createElement('p');
        a.href=new URL(p.url,root).href; a.textContent=p.title+(p.lang==='zh-en'?' · 中英对照':' · 中文');
        const at=Math.max(0,p.body.toLocaleLowerCase().indexOf(terms[0])-35); snippet.textContent=(at?'…':'')+p.body.slice(at,at+180)+'…';
        li.append(a,snippet);results.append(li);
      }
    } catch { header.textContent='搜索索引加载失败，请刷新后重试。'; dataPromise=undefined; }
  };
  toggle.addEventListener('click', () => {wrapper.classList.toggle('hidden');toggle.setAttribute('aria-expanded',String(!wrapper.classList.contains('hidden')));if(!wrapper.classList.contains('hidden'))input.focus();});
  input.addEventListener('input',search);
  input.closest('form')?.addEventListener('submit',e=>{e.preventDefault();search();});
  input.addEventListener('keydown',e=>{if(e.key==='Escape'){wrapper.classList.add('hidden');toggle.focus();}});
})();
