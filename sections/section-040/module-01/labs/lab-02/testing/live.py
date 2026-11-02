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

data=obj('configmap','cilium-config','kube-system')['data'];assert data.get('enable-wireguard')=='true', 'WireGuard is not enabled'
pods=json.loads(call('kubectl','-n','kube-system','get','pods','-l','k8s-app=cilium','-o','json'))['items']
assert len(pods)==2
for p in pods:
 text=call('kubectl','-n','kube-system','exec',p['metadata']['name'],'--','cilium-dbg','encrypt','status')
 assert 'wireguard' in text.lower(), 'Agent has no WireGuard encryption state'
probe=json.loads(call('kubectl','-n','starfleet','get','pods','-l','app=probe','-o','json'))['items'][0]
assert probe['spec']['nodeName']!=obj('pod','shuttle')['spec']['nodeName'], 'Clients must cross nodes'
