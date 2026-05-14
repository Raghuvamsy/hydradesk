#if os(macOS)
import Foundation
import CoreWLAN
import IOBluetooth

struct NetworkControlsState {
    var wifiOn: Bool
    var bluetoothOn: Bool
    var vpnStatus: String
}

final class NetworkControlService {
    func currentState() -> NetworkControlsState {
        let wifi = CWWiFiClient.shared().interface()?.powerOn() ?? false
        let bt = IOBluetoothHostController.default()?.powerState == .on
        return NetworkControlsState(wifiOn: wifi, bluetoothOn: bt, vpnStatus: "Unknown (public API limited)")
    }

    func setWiFi(enabled: Bool) {
        try? CWWiFiClient.shared().interface()?.setPower(enabled)
    }

    @discardableResult
    func setBluetooth(enabled: Bool) -> Bool {
        _ = enabled
        // Public macOS APIs do not provide a reliable Bluetooth power toggle for third-party apps.
        // We expose the intent and return false so callers can present clear UX fallback messaging.
        return false
    }
}
#endif
