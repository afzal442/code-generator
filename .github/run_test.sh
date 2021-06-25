#!/bin/bash

set -xeuo pipefail

if [ $1 == "generate" ]; then
    python ./tests/generate.py
elif [ $1 == "unittest" ]; then
    python ./tests/generate.py
    for dir in $(find ./tests/dist -type d -mindepth 1 -maxdepth 1 -not -path "./tests/dist/launch" -not -path "./tests/dist/spawn")
    do
        cd $dir
        pip install -r requirements.txt --progress-bar off -q
        cd ../../../
    done
    for dir in $(find ./tests/dist -type d -mindepth 1 -maxdepth 1 -not -path "./tests/dist/launch" -not -path "./tests/dist/spawn")
    do
        cd $dir
        pytest
        cd ../../../
    done
elif [ $1 == "default" ]; then
    python ./tests/generate.py
    for file in $(find ./tests/dist -iname "main.py" -not -path "./tests/dist/launch/*" -not -path "./tests/dist/spawn/*" -not -path "./tests/dist/single/*")
    do
        python $file \
            --verbose \
            --log_every_iters 2 \
            --num_workers 1 \
            --train_epoch_length 10 \
            --eval_epoch_length 10
    done
elif [ $1 == "launch" ]; then
    python ./tests/generate.py
    for file in $(find ./tests/dist/launch -iname "main.py" -not -path "./tests/dist/launch/single/*")
    do
        python -m torch.distributed.launch \
            --nproc_per_node 2 \
            --use_env $file \
            --verbose \
            --backend gloo \
            --num_workers 1 \
            --eval_epoch_length 10 \
            --train_epoch_length 10 \
            --log_every_iters 2
    done
elif [ $1 == "spawn" ]; then
    python ./tests/generate.py
    for file in $(find ./tests/dist/spawn -iname "main.py" -not -path "./tests/dist/spawn/single/*")
    do
        python $file \
            --verbose \
            --backend gloo \
            --num_workers 1 \
            --eval_epoch_length 10 \
            --train_epoch_length 10 \
            --nproc_per_node 2 \
            --log_every_iters 2
    done
fi