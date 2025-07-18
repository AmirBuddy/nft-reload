#!/bin/bash
set -e

echo "[*] Installing nft-reload to /usr/local/bin"
sudo install -m 0755 nft-reload /usr/local/bin/nft-reload
echo "[+] Installed. Run with: sudo nft-reload"
