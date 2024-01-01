# NYM Mixnode Status Checker

### Description:
This simple bash script is designed to identify specific Nym epochs in which a mixnode was active. It leverages journalctl to extract and analyze log entries

### System Requirements:
- Unix-like OS with systemd (common in most Linux distributions)
- `journalctl` must be available, typically as part of the systemd suite
- mixnode running as `nym-mixnode` service
