#!/usr/bin/env bash
# Esquema do registro JSON: o nome de cada campo em inglês e em português e o
# filtro jq que monta a linha (JSONL) a partir das métricas coletadas.

# Imprime o filtro jq. Ele espera --arg lang e ts, e --argjson cpu, freq, temp,
# mem, sys, disk e procs, todos na forma neutra produzida por core/collector.sh
# (a mesma em qualquer idioma). Só aqui os campos ganham nome.
record_filter() {
    cat <<'JQ'
def names: {
  en: {
    timestamp: "timestamp", cpu: "cpu", mhz_current: "mhz_current_avg",
    temperatures: "temperatures_c",
    memory: "memory", ram: "ram", swap: "swap",
    total: "total_bytes", used: "used_bytes", free: "free_bytes",
    shared: "shared_bytes", buff_cache: "buff_cache_bytes", available: "available_bytes",
    system: "system", uptime: "uptime_s", users: "users", cpu_threads: "cpu_threads",
    load: "load", avg_1m: "avg_1m", avg_5m: "avg_5m", avg_15m: "avg_15m",
    disk: "disk", device: "device", disk_used: "used_bytes", used_pct: "used_pct", mount: "mount",
    processes: "processes", command: "command", count: "count",
    cpu_pct: "cpu_pct", mem_pct: "mem_pct", rss_kb: "rss_kb", cpu_time: "cpu_time_s"
  },
  pt: {
    timestamp: "data_hora", cpu: "cpu", mhz_current: "mhz_atual_media",
    temperatures: "temperaturas_c",
    memory: "memoria", ram: "ram", swap: "swap",
    total: "total_bytes", used: "usada_bytes", free: "livre_bytes",
    shared: "compartilhada_bytes", buff_cache: "buff_cache_bytes", available: "disponivel_bytes",
    system: "sistema", uptime: "tempo_ligado_s", users: "usuarios", cpu_threads: "threads_cpu",
    load: "carga", avg_1m: "media_1m", avg_5m: "media_5m", avg_15m: "media_15m",
    disk: "disco", device: "dispositivo", disk_used: "usado_bytes", used_pct: "uso_pct", mount: "montagem",
    processes: "processos", command: "comando", count: "quantidade",
    cpu_pct: "cpu_pct", mem_pct: "mem_pct", rss_kb: "rss_kb", cpu_time: "tempo_cpu_s"
  }
};

names[$lang] as $k
| {
    ($k.timestamp): $ts,
    ($k.cpu): ($cpu + {($k.mhz_current): $freq}),
    ($k.temperatures): $temp,
    ($k.memory): {
      ($k.ram): {
        ($k.total): $mem.ram.total,
        ($k.used): $mem.ram.used,
        ($k.free): $mem.ram.free,
        ($k.shared): $mem.ram.shared,
        ($k.buff_cache): $mem.ram.buff_cache,
        ($k.available): $mem.ram.available
      },
      ($k.swap): {
        ($k.total): $mem.swap.total,
        ($k.used): $mem.swap.used,
        ($k.free): $mem.swap.free
      }
    },
    ($k.system): {
      ($k.uptime): $sys.uptime,
      ($k.users): $sys.users,
      ($k.cpu_threads): $sys.cpu_threads,
      ($k.load): {
        ($k.avg_1m): $sys.load.m1,
        ($k.avg_5m): $sys.load.m5,
        ($k.avg_15m): $sys.load.m15
      }
    },
    ($k.disk): ($disk | map({
      ($k.device): .device,
      ($k.total): .total,
      ($k.disk_used): .used,
      ($k.available): .available,
      ($k.used_pct): .used_pct,
      ($k.mount): .mount
    })),
    ($k.processes): ($procs | map({
      ($k.command): .command,
      ($k.count): .count,
      ($k.cpu_pct): .cpu_pct,
      ($k.mem_pct): .mem_pct,
      ($k.rss_kb): .rss_kb,
      ($k.cpu_time): .cpu_time
    }))
  }
JQ
}
