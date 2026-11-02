import json,subprocess,time,sys,tempfile,os

def call(*args):
 r=subprocess.run(list(args),text=True,capture_output=True,timeout=20)
 assert r.returncode==0, 'Observation command failed: '+args[0]
 return r.stdout.strip()
def obj(kind,name,ns='starfleet'):
 return json.loads(call('kubectl',*(['-n',ns] if ns else []),'get',kind,name,'-o','json'))
def api(path):
 script='import urllib.request; print(urllib.request.urlopen('+repr('http://prometheus:9090'+path)+',timeout=8).read().decode())'
 return json.loads(call('kubectl','-n','starfleet','exec','shuttle','--','python','-c',script))
def save(data):
 resource={'apiVersion':'v1','kind':'ConfigMap','metadata':{'name':'evidence','namespace':'starfleet'},'data':{'report.json':json.dumps(data,sort_keys=True)}}
 with tempfile.NamedTemporaryFile(mode='w',suffix='.json',delete=False) as f:json.dump(resource,f);path=f.name
 try:call('kubectl','apply','-f',path)
 finally:os.unlink(path)

assert call('kubectl','config','current-context') == 'kind-astro-ats-054-lab-030-01-01'
service=obj('service','probe');slices=json.loads(call('kubectl','-n','starfleet','get','endpointslices','-l','kubernetes.io/service-name=probe','-o','json'))['items']
assert any(e.get('conditions',{}).get('ready') for s in slices for e in s['endpoints'])
response=call('kubectl','-n','starfleet','exec','shuttle','--','python','-c',"import urllib.request; print(urllib.request.urlopen('http://probe:8080/',timeout=4).read().decode())")
report={'selector':service['spec']['selector'],'ports':service['spec']['ports'],'response':response}
save(report)
