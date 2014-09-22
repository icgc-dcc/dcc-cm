#!/bin/bash
sysctl -w kernel.shmmax=17179869184
sysctl -w kernel.shmall=4194304

