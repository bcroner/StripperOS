#!/usr/bin/env bash
# ==============================================================================
# StripperOS Kernel Trimming & High-Throughput Optimization Script
# License: MIT
# ==============================================================================

set -euo pipefail

log_os() {
    echo -e "\033[1;35m[StripperOS Kernel]\033[0m $1"
}

# Ensure script runs with bare-metal administrative privileges
if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] StripperOS compilation requires root privileges. Run with sudo." 
   exit 1
fi

log_os "Initiating surgical removal of legacy operating system bloat..."

# 1. Purge Desktop Environments, Telemetry, and Snap Frameworks
log_os "Purging tracking vectors and legacy user-space bloatware..."
apt-get purge -y snapd unattended-upgrades popularity-contest ubuntu-report \
                 whoopsie accountsservice modemmanager avahi-daemon x11-common \
                 desktop-file-utils &> /dev/null || true
apt-get autoremove -y &> /dev/null

# 2. Hard-Lock CPU Scaling Governors to Maximum Performance Mode
log_os "Configuring hardware registers for continuous performance throughput..."
if command -v cpufreq-set &> /dev/null; then
    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
        core_id=$(basename "$cpu")
        cpufreq-set -c "${core_id#cpu}" -g performance || true
    done
else
    # Direct fallback kernel write if utility tools are missing
    echo "performance" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor &> /dev/null || true
fi

# 3. Apply Low-Latency Real-Time Kernel Subsystem Parameters
log_os "Injecting low-latency system-level overrides into sysctl..."
cat << 'EOF' > /etc/sysctl.d/99-stripperos-latency.conf
# Secure maximum memory mapping efficiency for deep logic matrices
vm.max_map_count=262144

# Minimize swap file swapping to protect volatile memory lanes
vm.swappiness=0

# Maximize file descriptor boundaries for high-capacity network channels
fs.file-max=2097152

# Force immediate thread processing passes
kernel.sched_min_granularity_ns=100000
kernel.sched_wakeup_granularity_ns=100000
EOF
sysctl --system &> /dev/null

# 4. Configure Hard Resource Boundaries for Real-Time Execution
log_os "Locking infinite system resource limits for local processes..."
cat << 'EOF' > /etc/security/limits.d/99-stripperos-limits.conf
*               hard    memlock         unlimited
*               soft    memlock         unlimited
*               hard    nofile          65535
*               soft    nofile          65535
*               hard    rtprio          99
*               soft    rtprio          99
EOF

log_os "Operating system bloat successfully stripped. Bare-metal hardware optimized."

