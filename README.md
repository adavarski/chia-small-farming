## Chia: small home farm (ubuntu)


- ### Setup/Check Chia environment 

```
### Checkout the source, install and start (Ref: https://github.com/Chia-Network/chia-blockchain/wiki/INSTALL)
git clone https://github.com/Chia-Network/chia-blockchain.git -b latest --recurse-submodules
cd chia-blockchain
sh install.sh
. ./activate
chia version (1.1.6 for example)
chia keys generate
### Start full-node, farmer, harvester, wallet
chia start farmer 

# (OPTIONAL) The GUI requires you have Ubuntu Desktop or a similar windowing system installed.
sh install-gui.sh
cd chia-blockchain-gui
npm run electron &

### Setup FW/port forwarding FW_external_IP:8444->CHIA_NODE_IP:8444 (only needed during wallet sync)
### Check environment
nc -z -v ${FW_external_IP} 8444 (or using https://portchecker.co/) 

chia fram summary
chia wallet show
chia plots check
chia show -s -c
chia stop all && chia start farmer 

### Mount disks 
mount SATA SSD/NVMe SSD disks (2 Plotting NVMe SSDs: RAID0) for plots temp files -> /mnt/plots-tmp 
mount SATA HDD disks for plots (4 x WD Red Pro NAS HDD 16TB SATA: RAID0 ~ 700 k=32 plots) -> /mnt/plots 

### Test disks and R/W performance
sudo apt install smartmontools pv fio

sudo smartctl -t conveyance /dev/sdc
sudo smartctl -l selftest /dev/sdc
sudo smartctl --all /dev/sda
sudo smartctl --all /dev/sdc

dd if=/dev/zero of=/mnt/plots-tmp/test1.img bs=1G count=1 oflag=dsyn
pv -paterb /dev/zero > test_file
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=random_read_write.fio --bs=4k --iodepth=64 --size=1G --readwrite=randrw --rwmixread=75

### Test plots creation (default: -b 3389 -u 128)
chia plots create -k 32 -b 3389 -t /mnt/plots-tmp -d /mnt/plots -r 4 -u 128

```
- ### MadMax chia-plotter (pipelined multi-threaded)

This is a new implementation of a chia plotter which is designed as a processing pipeline, similar to how GPUs work, only the "cores" are normal software CPU threads. As a result this plotter is able to fully max out any storage device's bandwidth, simply by increasing the number of "cores", ie. threads.

```
### RAM disk setup on Linux
sudo mount -t tmpfs -o size=110G tmpfs /mnt/ramdisk/
Note: 128 GiB System RAM minimum required for RAM disk.

### Checkout the source and install MadMax chia-plotter
sudo apt install -y libsodium-dev cmake g++ git
git clone https://github.com/madMAx43v3r/chia-plotter.git 
cd chia-plotter
git submodule update --init
./make_devel.sh
./build/chia_plot --help

Note: The binaries will end up in build/, you can copy them elsewhere freely (on the same machine, or similar OS).
sudo cp build/chia_plot /usr/local/bin

### Run MadMax chia-plotter examples: 
Note: Get -p (public-pool-key) -f (farmer-public-key) form command output: 'chia keys show'
nohup chia_plot -n 1 -r 16 -u 128 -t /mnt/plots-tmp/disk1/ -2 /dev/shm/ -d /mnt/plots/disk1/ -p (public-pool-key) -f (farmer-public-key) > test.out 2>&1 &
chia_plot -n 200 -r 128 -t /mnt/plots-tmp/disk1/ -2 /mnt/ramdisk/ -d /mnt/plots/disk1/ -p (public-pool-key) -f (farmer-public-key)
chia_plot -n 16 -r 32 -u 128 -t /mnt/plots-tmp/disk1/ -2 /mnt/ramdisk/ -d /mnt/nfs/chia/ -p (public-pool-key) -f (farmer-public-key)
chia_plot -r 8 -t /mnt/plots-tmp/disk1/ -2 /mnt/ramdisk/ -d /mnt/plots/disk1/ -p (public-pool-key) -f (farmer-public-key)
chia_plot -n 1 -r 14 -u 128 -t /mnt/plots-tmp/disk1/ -2 /mnt/ramdisk/ -d /mnt/nfs/chia/
chia_plot -1 -r 18 -u 128 -t /mnt/plots-tmp/disk1/ -2 /mnt/ramdisk/ -d /mnt/plots/disk1/ -p (public-pool-key) -f (farmer-public-key)

### Run MadMax chia-plotter via screen example:
screen -L -Logfile /tmp/screen_chia.log -dmS chia chia_plot -n 1 -r 4 -u 128 -t /mnt/plots-tmp/disk1/ -d /mnt/plots/disk1/ -p a0d6533a5aa45a7b0d516c986265dc28ff1b5a1e6d51738ca138c6c4228724d2e8f262ab90ff4112ab42b4f2de61cf58 -f a35253798c9565f58759b0f32e51738875f873ecf31d5c12acd98e5c3c878c92a085e78bc248b7bbe00d03b9bb013666 

Note: to detach run: ctrl + a + d. Once detached you can check current screens with 'screen -ls'. Use 'screen -r' to attach a single screen or 'screen -r SCREEN_N' in case of multiple screens.

### Verify plots -> To make sure the plots are valid you can use the ProofOfSpace tool from chiapos:
git clone https://github.com/Chia-Network/chiapos.git
cd chiapos && mkdir build && cd build && cmake .. && make -j8
./ProofOfSpace check -f plot-k32-???.plot [num_iterations]

```
- ### Chia Plot Manager (to keep the plots generating)

Note: Slower plotting vs MadMax faster chia-plotter
```
### Install Chia Plot Manager 
cd ./plot-manager
python3 -m venv venv
. ./venv/bin/activate
pip install -r requirements.txt

### Edit and set up the config.yaml to your own personal settings. 

### Start chia plot manager
python manager.py start

### Check : python manager.py view

===================================================================================================================
num      job      k     pid           start          elapsed_time   phase    phase_times    progress   temp_size
===================================================================================================================
1     ssd-job     32   54932   2021-05-21 08:23:22   07:45:57       3       03:17 / 01:28   94.75%     157 GiB  
2     disk1_job   32   59032   2021-05-21 11:44:36   04:24:43       1                       31.27%     162 GiB  
===================================================================================================================
Manager Status: Running

====================================================================
type          drive             used     total    percent   plots
====================================================================
temp   /mnt/plots-tmp/disk1   0.15TiB   0.46TiB   35.4%     ?    
temp   /mnt/plots/tmp         1.54TiB   7.22TiB   22.5%     ?    
dest   /mnt/plots/disk1       1.54TiB   7.22TiB   22.5%     ?    
====================================================================
CPU Usage: 60.8%
RAM Usage: 5.04/15.53GiB(34.6%)

Plots Completed Yesterday: 5
Plots Completed Today: 4

Next log check at 2021-05-21 16:10:19



### Check : chia plot manager logs (example: tail -f $HOME/CHIA/logs/plotter/ssd-job_2021-05-15_12_29_50_943354.log )
```

- ### Chia Monitoring (plotting & farming)

```
### Install docker & docker-compose
sh ./utils/docker-install.sh

### Setup chia log level
chia configure -log-level INFO
chia stop all && chia start farmer

### Start chiamon
cd ./monitoring/docker-chiamon
docker-compose up -d
docker-compose ps
             Name                           Command               State   Ports
-------------------------------------------------------------------------------
docker-chiamon_chia_exporter_1   /usr/bin/chia_exporter -ce ...   Up           
docker-chiamon_grafana_1         /run.sh                          Up           
docker-chiamon_mtail_1           /usr/bin/mtail -progs /etc ...   Up           
docker-chiamon_node_exporter_1   /bin/node_exporter --path. ...   Up           
docker-chiamon_prometheus_1      /bin/prometheus --config.f ...   Up           
```
http://${CHIA_NODE_IP}:3000 (user/password: admin/admin)

#### Plot Manager (chiamon):

<img src="https://github.com/adavarski/chia-small-farming/blob/main/monitoring/docker-chiamon/chiamon.png" width="900">

#### MadMax chia-plotter (chiamon):

<img src="https://github.com/adavarski/chia-small-farming/blob/main/monitoring/docker-chiamon/chiamon-madmax-plotter.png" width="900">


