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

    func setBluetooth(enabled: Bool) {
        _ = enabled
    }
}
#endif
