# Independent read-only content auditor; writes mapping evidence, never translates or edits book content.
from html.parser import HTMLParser
from pathlib import Path
import json,re,hashlib,urllib.parse,xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[2]; SRC=ROOT/'pbr-book-website/4ed'
def norm(s):return re.sub(r'\s+',' ',s).strip()
def url(s):return urllib.parse.unquote(urllib.parse.urljoin('https://pbr-book.org/4ed/',s))
def digest(v):return hashlib.sha256(json.dumps(v,ensure_ascii=False,separators=(',',':')).encode()).hexdigest()
def svg_sig(raw):
    def one(e):return [e.tag.split('}')[-1],sorted((k.split('}')[-1],v) for k,v in e.attrib.items()),norm(e.text or ''),[one(c) for c in e]]
    return digest(one(ET.fromstring(raw)))
def compact(events):
    out=[]; buf=''
    for kind,val in events:
        if kind=='text':buf+=val;continue
        if buf:out.append(['text',norm(buf)]);buf=''
        out.append([kind,val])
    if buf:out.append(['text',norm(buf)])
    return [v for v in out if v!=['text','']]
class Source(HTMLParser):
    def __init__(self,raw,name):
        super().__init__(convert_charrefs=True);self.raw=raw;self.name=name;self.lines=raw.splitlines(keepends=True);self.offsets=[0]
        for l in self.lines:self.offsets.append(self.offsets[-1]+len(l))
        self.depth=0;self.group=None;self.gdepth=0;self.ul=0;self.row=None;self.rows=[];self.groups=[];self.svgstart=None;self.svgdepth=0;self.feed(raw)
    def pos(self):line,col=self.getpos();return self.offsets[line-1]+col
    def handle_starttag(self,tag,attrs):
        a=dict(attrs)
        if tag=='div':
            self.depth+=1
            if 'id' in a and len(a['id'])==1:
                self.group=a['id'];self.gdepth=self.depth;self.groups.append(self.group);self.ul=0
        if tag=='ul' and self.group:self.ul+=1
        if tag==('p' if self.name=='References' else 'li') and self.group and self.svgstart is None:
            if self.row is not None:raise RuntimeError(('nested row',self.name,self.getpos()))
            self.row={'source_line':self.getpos()[0],'group':self.group,'depth':self.ul,'events':[]}
        if self.row is None:return
        if tag=='svg':
            if self.svgstart is None:self.svgstart=self.pos()
            self.svgdepth+=1;return
        if self.svgstart is not None:return
        if tag=='a':self.row['events'].append(('open',url(a['href'])))
        if tag=='br':self.row['events'].append(('text',' '))
    def handle_endtag(self,tag):
        if self.svgstart is not None:
            if tag=='svg':
                self.svgdepth-=1
                if self.svgdepth==0:
                    raw=self.raw[self.svgstart:self.pos()+len('</svg>')];self.row['events'].append(('svg',svg_sig(raw)));self.svgstart=None
            return
        if self.row is not None:
            if tag=='a':self.row['events'].append(('close',''))
            if tag==('p' if self.name=='References' else 'li'):
                self.row['events']=compact(self.row['events']);self.rows.append(self.row);self.row=None
        if tag=='ul' and self.group:self.ul-=1
        if tag=='div':
            if self.depth==self.gdepth:self.group=None
            self.depth-=1
    def handle_data(self,d):
        if self.row is not None and self.svgstart is None:self.row['events'].append(('text',d))

def target(name):
    rows=[];groups=[];g=None;decoder=json.JSONDecoder();unknown=[]
    for no,l in enumerate((ROOT/'backmatter'/f'{name}.typ').read_text().splitlines(),1):
        if l.startswith('#heading(level:3'):
            g=l[l.index(')[')+2:-1].replace('\\\\','\\');groups.append(g)
        if '#par(hanging-indent:' not in l:continue
        ev=[];stack=[];mathmeta=[];i=l.index(')[',l.index('#par('))+2
        while i<len(l):
            if l.startswith('#original-math(',i):
                end=l.index(')',i)+1
                path,ht,dp,alt=json.loads('['+l[i+len('#original-math('):end-1]+']')
                raw=(ROOT/path.lstrip('/')).read_text(); e=ET.fromstring(raw)
                title=next(n.text or '' for n in e.iter() if n.tag.split('}')[-1]=='title')
                expected_height=float(e.attrib['height'].removesuffix('ex'))
                expected_depth=-float(re.search(r'vertical-align:\s*([\d.\-]+)ex',e.attrib['style']).group(1))
                mathmeta.append({'path':path,'height_ex':ht,'depth_ex':dp,'alt':alt,'metadata_match':ht==expected_height and dp==expected_depth and alt==title})
                ev.append(('svg',svg_sig(raw)));i=end;continue
            if l.startswith('#box[',i):stack.append('fmt');i+=len('#box[');continue
            if l.startswith('#text(size:9pt)[',i):stack.append('fmt');i+=len('#text(size:9pt)[');continue
            recognized=False
            for op in ['text','image','link']:
                prefix='#'+op+'('
                if l.startswith(prefix,i):
                    value,n=decoder.raw_decode(l[i+len(prefix):]);j=i+len(prefix)+n
                    end=l.index(')',j)+1
                    if op=='text':ev.append(('text',value));i=end
                    elif op=='image':ev.append(('svg',svg_sig((ROOT/value.lstrip('/')).read_text())));i=end
                    else:ev.append(('open',url(value)));stack.append('link');assert l[end]=='[';i=end+1
                    recognized=True;break
            if recognized:continue
            if l.startswith('#emph[',i):stack.append('fmt');i+=6;continue
            if l.startswith('#strong[',i):stack.append('fmt');i+=8;continue
            if l[i]==']':
                if stack and stack.pop()=='link':ev.append(('close',''))
                i+=1;continue
            if l[i].isspace():i+=1;continue
            unknown.append((name,no,l[i:i+30]));i+=1
        rows.append({'local_line':no,'group':g,'depth':(2 if l.startswith('#block(inset:') else 1) if name=='Index_of_Identifiers' else (0 if name=='References' else 1),'events':compact(ev),'math':mathmeta})
    return groups,rows,unknown
class Anchors(HTMLParser):
    def __init__(self,raw):super().__init__(convert_charrefs=True);self.ids=set();self.feed(raw)
    def handle_starttag(self,t,a):
        for k,v in a:
            if k=='id' or (t=='a' and k=='name'):self.ids.add(v)
cache={};linkchecks={}
def check_link(link):
    u=urllib.parse.urlsplit(link)
    if u.netloc!='pbr-book.org' or not u.path.startswith('/4ed/'):return None
    p=SRC/u.path.removeprefix('/4ed/')
    if link in linkchecks:return linkchecks[link]
    result={'url':link,'source_target':str(p.relative_to(ROOT)),'fragment':u.fragment,'file_exists':p.is_file()}
    if p.is_file():
        if str(p) not in cache:cache[str(p)]=Anchors(p.read_text()).ids
        result['anchor_exists']=(not u.fragment or u.fragment in cache[str(p)])
    else:result['anchor_exists']=False
    linkchecks[link]=result;return result
def equivalent(events):
    out=[];active=False
    for k,v in events:
        if k=='open':
            if active:out.append(['close',''])
            u=urllib.parse.urlsplit(v)
            if not u.path:v=urllib.parse.urlunsplit((u.scheme,u.netloc,'/',u.query,u.fragment))
            out.append([k,v]);active=True
        elif k=='close':
            if active:out.append([k,v]);active=False
        else:out.append([k,v])
    return out
summary={};evidence=[];failures=[]
for name in ['References','Index_of_Fragments','Index_of_Identifiers']:
    source=Source((SRC/f'{name}.html').read_text(),name);groups,rows,unknown=target(name)
    assert len(source.rows)==len(rows), (name,'unpaired source/local entries',len(source.rows),len(rows))
    summary[name]={'source_rows':len(source.rows),'target_rows':len(rows),'source_groups':source.groups,'target_groups':groups,'groups_match':source.groups==groups,'unknown_target_tokens':unknown[:20],'depths':sorted(set(r['depth'] for r in source.rows))}
    for i,(s,t) in enumerate(zip(source.rows,rows),1):
        exact=s['events']==t['events'];eq=equivalent(s['events'])==equivalent(t['events']);match=s['group']==t['group'];record={'document':name,'ordinal':i,'source':f'4ed/{name}.html','source_line':s['source_line'],'source_group':s['group'],'source_list_depth':s['depth'],'local':f'backmatter/{name}.typ','local_line':t['local_line'],'content_match':eq,'exact_events_match':exact,'group_match':match,'hierarchy_match':s['depth']==t['depth'],'source_events':s['events'],'local_events':t['events'],'source_sha256':digest(s['events']),'local_sha256':digest(t['events']),'math':t['math']}
        record['local_source_targets']=[check_link(v) for k,v in t['events'] if k=='open' and check_link(v) is not None]
        evidence.append(record)
        if not eq or not match or s['depth']!=t['depth']:failures.append(record)
    summary[name]['mismatches']=sum(1 for f in failures if f['document']==name)
summary['internal_links']={'occurrences':sum(len(r['local_source_targets']) for r in evidence),'unique':len(linkchecks),'failed':[r for r in linkchecks.values() if not r['file_exists'] or not r['anchor_exists']]}
summary['accepted_html_or_url_normalizations']=sum(not r['exact_events_match'] for r in evidence)
summary['svg_occurrences']=sum(k=='svg' for r in evidence for k,v in r['source_events'])
summary['math_metadata_failures']=[{'document':r['document'],'ordinal':r['ordinal'],'math':m} for r in evidence for m in r['math'] if not m['metadata_match']]
summary['svg_files']=len(list((ROOT/'backmatter/math').glob('*.svg')))
(ROOT/'audit/reports/backmatter-mapping-evidence.jsonl').write_text(''.join(json.dumps(r,ensure_ascii=False)+'\n' for r in evidence))
(ROOT/'audit/reports/backmatter-audit-summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2))
Path('/tmp/backmatter-mismatches.json').write_text(json.dumps(failures,ensure_ascii=False,indent=2))
print(json.dumps(summary,ensure_ascii=False,indent=2))
print('first_mismatches',json.dumps(failures[:3],ensure_ascii=False))

import sys
sys.exit(1 if failures or summary["math_metadata_failures"] or summary["internal_links"]["failed"] or any(not summary[n]["groups_match"] or summary[n]["unknown_target_tokens"] for n in ["References","Index_of_Fragments","Index_of_Identifiers"]) else 0)
