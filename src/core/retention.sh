#!/usr/bin/env bash
# Retenção dos relatórios diários.

# Apaga relatórios com mais de SYSMETRICS_MAX_DAYS dias. Só toca em system_*.log.
cleanup_old_logs() {
    [[ -d "$SYSMETRICS_LOG_DIR" ]] || return 0
    find "$SYSMETRICS_LOG_DIR" -maxdepth 1 -type f -name 'system_*.log' \
        -mmin +"$((SYSMETRICS_MAX_DAYS * 1440))" -delete
}
