# NYM Mixnode Active Epoch Checker

### Description:
This simple bash script is designed to identify specific [Nym](https://nymtech.net/) epochs in which a mixnode was active. It leverages journalctl to extract and analyze log entries

### System Requirements:
- Unix-like OS with systemd
- `journalctl` must be available
- mixnode running as `nym-mixnode` service

### Download and run
```
wget -qO mixnode_activity.sh https://raw.githubusercontent.com/toolfun/Nym-mixnode-activity-checker/main/script/mixnode_activity.sh && chmod +x mixnode_activity.sh && ./mixnode_activity.sh
```

### Run    
```
./mixnode_activity.sh
```
