#!/bin/bash
screen -dmS chia chia_plot -n 1 -r 4 -u 128 -t /mnt/plots-tmp/disk1/ -d /mnt/plots/disk1/ -p a0d6533a5aa45a7b0d516c986265dc28ff1b5a1e6d51738ca138c6c4228724d2e8f262ab90ff4112ab42b4f2de61cf58 -f a35253798c9565f58759b0f32e51738875f873ecf31d5c12acd98e5c3c878c92a085e78bc248b7bbe00d03b9bb013666 |tee /tmp/chia.log &
