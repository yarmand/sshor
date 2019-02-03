sshor
=====

SSH automatic callback

# setup

- You will need a cloud synced account (Dropbox, Onedrive ...) to host sshor
- create a ssh keypair
```
ssh-keygen -t rsa -b 4096 -f ~/.ssh/sshor
```
(leave passphrase empty to allow the connection script to run without uman input)
- copy sshor.pub key as ~/.ssh/authorised_keys

# usage

(super basic usage)

1. connect to your home VPN and note the IP adress you get
1. put a file named with the IP you find above
1. DropBox or Onedrive should sync it
1. sshor create establish connection from server machine to your vpn connected computer
1. sshor create a connection script to be used on your laptop
1. source that connection script
1. (Optionnal) connection to remote desktop using the LOCAL_PORT

you can find better explanation of the process on project [webpair](https://github.com/yarmand/webpair)
