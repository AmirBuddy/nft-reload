# nft-reload

`nft-reload` is a small shell tool to **safely restart nftables** without breaking your existing `iptables`/`ip6tables` rules when using the `iptables-nft` backend.

---

### Why?

When using the `iptables-nft` backend, your system lets `iptables` commands operate on the underlying `nftables` ruleset.
However, **directly applying or restarting nftables rules** (like with `nft -f /etc/nftables.conf` or `systemctl restart nftables`) will **wipe out all the iptables-injected rules**.

This breaks services like:

* Docker (which manages iptables rules dynamically)
* Firewalls that use legacy iptables commands
* Scripts or tools that apply iptables rules on the fly

---

### What This Tool Does

`nft-reload` preserves your system state by:

1. Saving current IPv4 and IPv6 iptables rules.
2. Restarting nftables cleanly.
3. Restoring the saved iptables rules back into the nftables-compatible backend.

This way, **you can use `nftables` as your main firewall** and still maintain compatibility with any tool that relies on `iptables`.

---

### Installation

```bash
sudo cp nft-reload /usr/local/bin/
sudo chmod +x /usr/local/bin/nft-reload

# Or use the installer script:
sudo ./install.sh
```

---

### Prerequisites

Make sure your system is configured to use **nftables** and the **iptables-nft** backend.

#### 1. Enable nftables, disable legacy iptables:

```bash
sudo systemctl stop iptables 2>/dev/null
sudo systemctl disable iptables 2>/dev/null
sudo systemctl mask iptables 2>/dev/null

sudo systemctl enable --now nftables
```

#### 2. Set iptables to use the nftables backend:

```bash
sudo update-alternatives --set iptables /usr/sbin/iptables-nft
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-nft
sudo update-alternatives --set arptables /usr/sbin/arptables-nft
sudo update-alternatives --set ebtables /usr/sbin/ebtables-nft
```

#### 3. Verify:

```bash
sudo iptables -V
```

Should output something like:

```
iptables v1.8.10 (nf_tables)
```

---

### Usage

Simply run:

```bash
sudo nft-reload
```

This will:

* Backup current iptables/ip6tables rules to `/tmp`
* Restart nftables
* Restore the backed-up rules

---

### Example Scenario

1. You use `iptables` to block ping:

   ```bash
   sudo iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
   ```

2. You apply a new nftables config:

   ```bash
   sudo nft-reload
   ```

Your iptables rule still works after reload.

---

### Notes

* Script uses `/tmp` for storing temporary backups — ephemeral by design.
* You can adapt it to save versioned backups or logs if needed.
* You can turn this into a systemd wrapper if you prefer automation.

---

### License

MIT — use freely and improve.
