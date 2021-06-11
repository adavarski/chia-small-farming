TODO: 

HOWTOs:

```
### To Update/Upgrade from previous version
cd chia-blockchain


. ./activate
chia stop -d all
tar -cvf /home/davar/CHIA/backup/chia-backup."$(date '+%Y-%m-%d').1.1.4.tar"  /home/davar/.chia

deactivate
git fetch
git checkout latest
git reset --hard FETCH_HEAD

# If you get RELEASE.dev0 then delete the package-lock.json in chia-blockchain-gui and install.sh again

git status

# git status should say "nothing to commit, working tree clean", 
# if you have uncommitted changes, RELEASE.dev0 will be reported.

sh install.sh

. ./activate

chia version (can be 1.1.5 for example)
chia init
chia start farmer

# The GUI requires you have Ubuntu Desktop or a similar windowing system installed.
# You can not install and run the GUI as root
cd chia-blockchain-gui
git fetch
cd ..
chmod +x ./install-gui.sh
./install-gui.sh

cd chia-blockchain-gui
npm run electron &


```
