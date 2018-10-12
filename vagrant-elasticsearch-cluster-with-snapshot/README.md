#### With this code files, we will install and configure Elasticsearch cluster with **4** nodes. Master node **elk** and slave nodes **elknd1**, **elknd2**, **elknd3**

#### When cluster will be UP and ready scripts will download some sample databases from Internet to the **elknd3** node and through master elk (Actually there is no difference between nodes and we can use any of the nodes to upload) API upload them inside of the Elasticsearch. In the Elasticsearch databases named as the Indices. Scripts will check Indices count if count will be as needed then it will configure Snapshot for the all nodes. For that in the master (**elk**) node will be configured NFS server and this configured folder will be mounted to the other (**elknd1**, **elknd2**, **elknd3**) nodes. In the end, the snapshot will be configured through API and executed to get the first one.

##### Vagrant Virtual machines:
```bash
elk
elknd1
elknd2
elknd3
```

##### Look at the content of the [Vagrantfile](https://github.com/jamalshahverdiev/vagrant-elasticsearch-cluster-with-snapshot/blob/master/Vagrantfile)

##### From Vagrantfile we can see the **elk** node IP will be **192.168.120.40** and __install.sh__ , __elkinstall.sh__ , __nfssrvconf.sh__ provisioning codes after deployment. For the **elknd1** , **elknd2** , **elknd3** provisioning codes will be __install.sh__ and __elknodes.sh__ scripts.

##### Let’s start analyzing provision codes. Firstly, we start to describe the __install.sh__ script because it is used for all servers.

##### The [install.sh](https://github.com/jamalshahverdiev/vagrant-elasticsearch-cluster-with-snapshot/blob/master/scripts/install.sh) script installs all needed components and Oracle Java to the Linux.


##### Now we will explain elk master node provisioning scripts. In the [elkinstall.sh](https://github.com/jamalshahverdiev/vagrant-elasticsearch-cluster-with-snapshot/blob/master/scripts/elkinstall.sh) script will be configured official Elasticsearch repository. Then will be installed Elasticsearch (with cluster configuration), Kibana and Logstash. In the end, all services will be started and enabled.

##### With the [nfssrvconf.sh](https://github.com/jamalshahverdiev/vagrant-elasticsearch-cluster-with-snapshot/blob/master/scripts/nfssrvconf.sh) script will be configured NFS server to the SNAPSHOT folder with access only **elknd1**, **elknd2**, and **elknd3**. Service will be started and enabled.

##### Let’s start to explain **elknd1**, **elknd2**, and **elknd3** servers provisioning. The script [elknodes.sh](https://github.com/jamalshahverdiev/vagrant-elasticsearch-cluster-with-snapshot/blob/master/scripts/elknodes.sh) configure Elasticsearch repository, install package and configure needed files. Then start and enable service to all nodes.

##### Script [importDataGetSnapshot.sh](https://github.com/jamalshahverdiev/vagrant-elasticsearch-cluster-with-snapshot/blob/master/scripts/importDataGetSnapshot.sh) mount exported NFS disk to the needed PATH for the snapshots. Then will check if OS hostname is **elknd3** and cluster up and running then, download some databases and import to the Elasticsearch through API. After that checking indices count and if it is right it will configure Snapshot through API and start it. All snapshots will be stored in the **/etc/elasticsearch/elasticsearch-backup** folder.

##### **vagrant-provision-reboot-plugin.rb** is the plugin file for the vagrant which will be used to reboot after deployment.

##### To execute the environment just download all code files from Git repository and run Vagrant.
```bash
# git clone https://github.com/jamalshahverdiev/vagrant-elasticsearch-cluster-with-snapshot.git
# cd vagrant-elasticsearch-cluster-with-snapshot && vagrant up
```


#### To restore Snapshot from CLUSTER1 to the CLUSTER2 just configure CLUSTER2(Snapshot must be configured via API but not executed) as the CLUSTER1 and execute the following steps.
##### In the **CLUSTER1** archive content of the **/etc/elasticsearch/elasticsearch-backup** folder to the **elksnapshot.tar.gz** file:
```bash
# cd /etc/elasticsearch/elasticsearch-backup && tar -zcvf elksnapshot.tar.gz .
```


##### In the **CLUSTER2** upload the archived **elksnapshot.tar.gz** file from **CLUSTER1** to the **/etc/elasticsearch/elasticsearch-backup** folder and then extract it:
```bash
# cp /root/elksnapshot.tar.gz /etc/elasticsearch/elasticsearch-backup
# cd /etc/elasticsearch/elasticsearch-backup && tar -zxvf elksnapshot.tar.gz
```

##### Configure snapshot PATH in the cluster:
```bash
# curl -s -H 'Content-Type: application/json' -XPUT "http://192.168.120.40:9200/_snapshot/all-backup" -d '
{
   "type": "fs",
   "settings": {
       "compress" : true,
       "location": "/etc/elasticsearch/elasticsearch-backup"
   }
}'
```

##### Look at the snapshot which you created before and extracted arcive from previous Snapshot (As we can see we have **5** indices, **3** logstash, **1** bank and **1** Shakespeare):
```bash
[root@elkmaster elasticsearch-backup]# curl -s -H 'Content-Type: application/json' -XGET "http://192.168.120.40:9200/_snapshot/all-backup/_all" | jq
{
  "snapshots": [
    {
      "snapshot": "snapshot-number-one",
      "uuid": "M-I1bd-YT22V6MgEhBvbJA",
      "version_id": 6040099,
      "version": "6.4.0",
      "indices": [
        "logstash-2015.05.18",
        "logstash-2015.05.20",
        "bank",
        "logstash-2015.05.19",
        "shakespeare"
      ],
      "include_global_state": true,
      "state": "SUCCESS",
      "start_time": "2018-09-12T07:06:59.188Z",
      "start_time_in_millis": 1536736019188,
      "end_time": "2018-09-12T07:07:04.184Z",
      "end_time_in_millis": 1536736024184,
      "duration_in_millis": 4996,
      "failures": [],
      "shards": {
        "total": 25,
        "failed": 0,
        "successful": 25
      }
    }
  ]
}
```


##### If you try to get list of the indices it will be empty:
```bash
# curl -s -H 'Content-Type: application/json' -XGET "http://192.168.120.40:9200/_cat/indices"
```

##### Restore **snapshot-number-one** which we created in the **CLUSTER1**:
```bash
# curl -s -H 'Content-Type: application/json' -XPOST "http://192.168.120.40:9200/_snapshot/all-backup/snapshot-number-one/_restore"
{"accepted":true}
```

##### Look at the indices count:
```bash
# curl -s -H 'Content-Type: application/json' -XGET "http://192.168.120.40:9200/_cat/indices"
green open shakespeare         pq4620uoQOiXXC-lQKwi-Q 5 1 111396 0  45.8mb 22.9mb
green open logstash-2015.05.18 QlFO8vHxSPyBBZ0JbKa0mw 5 1   4631 0  51.5mb 25.7mb
green open logstash-2015.05.20 4LxKjqnVTMaKI_QYzZIycA 5 1   4750 0  47.7mb 26.1mb
green open logstash-2015.05.19 TPoE-3SdRiqDmPHGs2MLIQ 5 1   4624 0  48.1mb   25mb
green open bank                tgU6Om8pRfKklNvzo9riaA 5 1   1000 0 950.1kb  475kb
```

##### Look at the selected Snapshot:
```bash
[root@elkmaster elasticsearch-backup]# curl -s -H 'Content-Type: application/json' -XGET "http://192.168.120.40:9200/_snapshot/all-backup/snapshot-number-one" | jq
{
  "snapshots": [
    {
      "snapshot": "snapshot-number-one",
      "uuid": "M-I1bd-YT22V6MgEhBvbJA",
      "version_id": 6040099,
      "version": "6.4.0",
      "indices": [
        "logstash-2015.05.18",
        "logstash-2015.05.20",
        "bank",
        "logstash-2015.05.19",
        "shakespeare"
      ],
      "include_global_state": true,
      "state": "SUCCESS",
      "start_time": "2018-09-12T07:06:59.188Z",
      "start_time_in_millis": 1536736019188,
      "end_time": "2018-09-12T07:07:04.184Z",
      "end_time_in_millis": 1536736024184,
      "duration_in_millis": 4996,
      "failures": [],
      "shards": {
        "total": 25,
        "failed": 0,
        "successful": 25
      }
    }
  ]
}
```
