#!/bin/bash

echo "Setting up your environment..."

echo "export PATH=$PATH:${PWD}/bin" >> ~/.bashrc

source ~/.bashrc

echo "Creating the data directory..."

touch ${HOME}/.repos.csv

echo "Done!"

