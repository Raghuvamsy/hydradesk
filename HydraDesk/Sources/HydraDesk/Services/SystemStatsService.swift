#if os(macOS)
import Foundation
import IOKit.ps
import Darwin

final class SystemStatsService {
    private var lastNetworkBytes: (input: UInt64, output: UInt64, time: Date)?

    func snapshot() -> SystemStatsSnapshot {
        let cpu = cpuUsage()
        let mem = memoryUsage()
        let disk = diskUsage()
        let battery = batteryStatus()
        let net = networkSpeed()

        return SystemStatsSnapshot(
            cpuUsage: cpu,
            memoryUsedGB: mem.used,
            memoryTotalGB: mem.total,
            diskUsedGB: disk.used,
            diskTotalGB: disk.total,
            batteryPercent: battery.percent,
            batteryIsCharging: battery.isCharging,
            networkDownKBps: net.downKBps,
            networkUpKBps: net.upKBps
        )
    }

    private func cpuUsage() -> Double {
        var size = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.stride / MemoryLayout<integer_t>.stride)
        var info = host_cpu_load_info()
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
            }
        }
        guard result == KERN_SUCCESS else { return 0 }

        let user = Double(info.cpu_ticks.0)
        let sys = Double(info.cpu_ticks.1)
        let idle = Double(info.cpu_ticks.2)
        let nice = Double(info.cpu_ticks.3)
        let total = user + sys + idle + nice
        guard total > 0 else { return 0 }
        return ((user + sys + nice) / total) * 100
    }

    private func memoryUsage() -> (used: Double, total: Double) {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return (0, 0) }

        let pageSize = Double(vm_kernel_page_size)
        let used = Double(stats.active_count + stats.inactive_count + stats.wire_count) * pageSize / 1_073_741_824
        let total = Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824
        return (used, total)
    }

    private func diskUsage() -> (used: Double, total: Double) {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
              let total = attrs[.systemSize] as? NSNumber,
              let free = attrs[.systemFreeSize] as? NSNumber else {
            return (0, 0)
        }
        let totalGB = total.doubleValue / 1_073_741_824
        let usedGB = (total.doubleValue - free.doubleValue) / 1_073_741_824
        return (usedGB, totalGB)
    }

    private func batteryStatus() -> (percent: Double?, isCharging: Bool) {
        guard let blob = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(blob)?.takeRetainedValue() as? [CFTypeRef],
              let source = sources.first,
              let desc = IOPSGetPowerSourceDescription(blob, source)?.takeUnretainedValue() as? [String: Any] else {
            return (nil, false)
        }

        let current = (desc[kIOPSCurrentCapacityKey as String] as? NSNumber)?.doubleValue
        let max = (desc[kIOPSMaxCapacityKey as String] as? NSNumber)?.doubleValue
        let charging = (desc[kIOPSPowerSourceStateKey as String] as? String) == kIOPSACPowerValue

        if let current, let max, max > 0 {
            return ((current / max) * 100, charging)
        }
        return (nil, charging)
    }

    private func networkSpeed() -> (downKBps: Double, upKBps: Double) {
        var addresses: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&addresses) == 0, let first = addresses else { return (0, 0) }
        defer { freeifaddrs(addresses) }

        var totalIn: UInt64 = 0
        var totalOut: UInt64 = 0
        var cursor: UnsafeMutablePointer<ifaddrs>? = first

        while let iface = cursor?.pointee {
            if iface.ifa_addr.pointee.sa_family == UInt8(AF_LINK),
               let data = UnsafeMutableRawPointer(iface.ifa_data)?.assumingMemoryBound(to: if_data.self) {
                totalIn += UInt64(data.pointee.ifi_ibytes)
                totalOut += UInt64(data.pointee.ifi_obytes)
            }
            cursor = iface.ifa_next
        }

        let now = Date()
        guard let last = lastNetworkBytes else {
            lastNetworkBytes = (totalIn, totalOut, now)
            return (0, 0)
        }

        let elapsed = now.timeIntervalSince(last.time)
        guard elapsed > 0 else { return (0, 0) }

        let down = Double(totalIn &- last.input) / elapsed / 1024
        let up = Double(totalOut &- last.output) / elapsed / 1024
        lastNetworkBytes = (totalIn, totalOut, now)
        return (max(0, down), max(0, up))
    }
}
#endif
