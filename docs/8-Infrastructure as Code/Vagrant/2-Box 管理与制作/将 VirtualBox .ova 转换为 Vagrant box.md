Here's a step by step guide to convert a Virtualbox .ova to a Vagrant box.

1. List your VMs to find the VM id you want to convert:

```
$ VBoxManage list vms
"testing" {a3f59eed-b9c5-4a5f-9977-187f8eb8c4d4}
```

2. You can now package the .ova VM as Vagrant box:

```
$ vagrant package --base a3f59eed-b9c5-4a5f-9977-187f8eb8c4d4 --output name-of-your-box.box

```

the command `vagrant package` runs for quite some time before it can creates a Vagrant box. Be faithful and wait.

3. Add the new box to the list of local Vagrant boxes:

```
$ vagrant box add new-box-name name-of-your-box.box
vagrant box add --name
```

4. Init, up, ssh and start usign your Vagrant box:
```
$ vagrant init #Init the new box with a Vagrantfile
$ vagrant up
$ vagrant ssh
```
And enjoy!