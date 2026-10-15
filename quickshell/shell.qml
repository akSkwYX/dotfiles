import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

ShellRoot {
   id: root
   property string popup: ""

   NotificationPopup {}

   function toggle(name) {
      popup = (popup === name) ? "" : name
   }

   IpcHandler { target: "launcher"; function toggle(): void { root.toggle("launcher") } }
   IpcHandler { target: "volume"; function toggle(): void { root.toggle("volume") } }
   IpcHandler { target: "wifi"; function toggle(): void { root.toggle("wifi") } }
   IpcHandler { target: "bluetooth"; function toggle(): void { root.toggle("bluetooth") } }

   LauncherPopup {
      open: root.popup === "launcher"
      onCloseRequested: root.popup = ""
   }
   VolumePopup {
      open: root.popup === "volume"
      onCloseRequested: root.popup = ""
   }
   WifiPopup {
      open: root.popup === "wifi"
      onCloseRequested: root.popup = ""
   }
   BluetoothPopup {
      open: root.popup === "bluetooth"
      onCloseRequested: root.popup = ""
   }

}
