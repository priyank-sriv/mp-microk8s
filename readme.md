## Multipass+MicroK8s

### About


### Instructions

#### Clone repo

```sh
$ git clone https://github.com/priyank-sriv/mp-microk8s.git
```

#### Launching VM

```sh
$ cd scripts/
$ chmod +x mp-compose.sh
$ ./mp-compose.sh up <VM_NAME>
```

#### Connecting to VM shell

```sh
$ ./mp-compose.sh connect <VM_NAME>
```

#### Installing MicroK8s

```sh
$ cd /multipass/volume/scripts
$ chmod +x install.sh
$ ./install.sh
```

#### Accessing Kubernetes dashboard
From the host machine, run:
```sh
$ multipass list
```
Copy the ip address from the IPv4 column: <EXTERNAL_IP>

Load in browser: `http://<EXTERNAL_IP>:59001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/`

#### Test installation

[microbot example](https://tutorials.ubuntu.com/tutorial/install-a-local-kubernetes-with-microk8s#4)

#### Alias for script


### Variables
`VM_IMG=${VM_IMG:-"lts"}`

`VM_MEM=${VM_MEM:-4G}`

`VM_CPUS=${VM_CPUS:-2}`

and more...


### Supported Environments
- MacOSX
- Ubuntu 18.04+
