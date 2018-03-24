#!/bin/bash

export PORT=5104

cd ~/www/jivi
./bin/jivi stop || true
./bin/jivi start

