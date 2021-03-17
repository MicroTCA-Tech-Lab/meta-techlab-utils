#! /bin/bash

SIZE=$((128*1024*1024))
echo "init udmabuf with size $SIZE"

modprobe u_dma_buf udmabuf0=$SIZE

