export CUCUMBER_SSHD_DEBUG=yes
export CUCUMBER_SSHD_LISTEN=127.0.0.1

ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
