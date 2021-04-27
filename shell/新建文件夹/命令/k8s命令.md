

## 软链接



```sh
file1=calicoctl
ln -sf /etc/ansible/bin/${file1} /usr/bin/${file1} 
```



```sh
#/bin/sh
file1=(
    calicoctl
    etcdctl
)

for str in ${file1[@]}; do
    #ln -sf /etc/ansible/bin/$str /usr/bin/$str
done

```









```bash
kubectl get pod -n kube-system	# 验证新节点的网络插件calico 或flannel 的Pod 状态
$ kubectl version         # 验证集群版本     
$ kubectl get node        # 验证节点就绪 (Ready) 状态
$ kubectl get pod -A      # 验证集群pod状态，默认已安装网络插件、coredns、metrics-server等
$ kubectl get svc -A      # 验证集群服务状态
```











### 

```sh
echo $(kubectl -n kube-system get secret $(kubectl -n kube-system get secret | grep kuboard-user | awk '{print $1}') -o go-template='{{.data.token}}' | base64 -d)
```





### 获取 calico 的版本：

```sh
kubectl describe deployment calico-kube-controllers -n kube-system
```



### 创建 YAML 文件

创建文件 nginx-deployment.yaml，内容如下：

- 有注释
- 无注释

```yaml
apiVersion: apps/v1	#与k8s集群版本有关，使用 kubectl api-versions 即可查看当前集群支持的版本
kind: Deployment	#该配置的类型，我们使用的是 Deployment
metadata:	        #译名为元数据，即 Deployment 的一些基本属性和信息
  name: nginx-deployment	#Deployment 的名称
  labels:	    #标签，可以灵活定位一个或多个资源，其中key和value均可自定义，可以定义多组，目前不需要理解
    app: nginx	#为该Deployment设置key为app，value为nginx的标签
spec:	        #这是关于该Deployment的描述，可以理解为你期待该Deployment在k8s中如何使用
  replicas: 1	#使用该Deployment创建一个应用程序实例
  selector:	    #标签选择器，与上面的标签共同作用，目前不需要理解
    matchLabels: #选择包含标签app:nginx的资源
      app: nginx
  template:	    #这是选择或创建的Pod的模板
    metadata:	#Pod的元数据
      labels:	#Pod的标签，上面的selector即选择包含标签app:nginx的Pod
        app: nginx
    spec:	    #期望Pod实现的功能（即在pod中部署）
      containers:	#生成container，与docker中的container是同一种
      - name: nginx	#container的名称
        image: nginx:1.7.9	#使用镜像nginx:1.7.9创建container，该container默认80端口可访问
 
```





### 应用 YAML 文件

```sh
kubectl apply -f nginx-deployment.yaml
 
```



## node

### 看所有节点的列表：

```sh
kubectl get nodes -o wide
```



### 查看节点状态以及节点的其他详细信息：

```sh
kubectl describe node <your-node-name>
 
```



## 查看所有calico节点状态

```
calicoctl node status
```



## 验证 BGP Peer

> BGP 协议是通过TCP 连接来建立邻居的，因此可以用netstat 命令验证 BGP Peer

```sh
netstat -antlp|grep ESTABLISHED|grep 179
tcp        0      0 192.168.1.66:179        192.168.1.35:41316      ESTABLISHED 28479/bird      
tcp        0      0 192.168.1.66:179        192.168.1.34:40243      ESTABLISHED 28479/bird      
tcp        0      0 192.168.1.66:179        192.168.1.63:48979      ESTABLISHED 28479/bird
```

