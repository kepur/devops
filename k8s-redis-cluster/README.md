showmount -e 10.25.96.30
mount -t nfs 10.25.96.30:/opt/kubernetes/volums /usr/local/kubernetes/volumes
rm -rf /usr/local/kubernetes/volumes/redis-data
mkdir -p /usr/local/kubernetes/volumes/redis-data/redis-cluster-{1,2,3}
chmod -R a+rw /usr/local/kubernetes/volumes/redis-data


kubectl delete -f redis-pv1.yaml
kubectl delete -f redis-pv2.yaml
kubectl delete -f redis-pv3.yaml
kubectl create -f redis-pv1.yaml
kubectl create -f redis-pv2.yaml
kubectl create -f redis-pv3.yaml
kubectl create -f redis-configmap.yaml
kubectl create -f redis-stafulset-master-deployment.yaml
kubectl create -f redis-stafulset-deployment.yaml

# kubectl exec -ti redis-cluster-master-0 -- redis-cli
127.0.0.1:6379> set hozin wolihi
OK
127.0.0.1:6379> exit
# kubectl exec -ti redis-cluster-slave-0 -- redis-cli
127.0.0.1:6379> get hozin
"wolihi"
127.0.0.1:6379>

kubectl exec -ti redis-cluster-slave-0 -n default -- redis-cli -h redis-cluster-master-svc info replication

# kubectl exec -ti redis-cluster-slave-0 -n default -- redis-cli -h redis-cluster-master-svc info replication
# Replication
role:master
connected_slaves:2
slave0:ip=10.1.166.182,port=6379,state=online,offset=367,lag=1
slave1:ip=10.1.104.23,port=6379,state=online,offset=367,lag=0
master_replid:dbb6668aaa33d2a825caa5895edcc51d9ff35d73
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:367
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:367
[root@master k8s-redis-cluster]#
