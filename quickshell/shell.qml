import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

ShellRoot {
   id: root
   property bool launcherOpen: false
   property bool volumeOpen: false

   IpcHandler {
      target: "launcher"
      function toggle(): void { 
         root.volumeOpen = false
         root.launcherOpen = !root.launcherOpen 
      }
      function open(): void { root.launcherOpen = true }
      function close(): void { root.launcherOpen = false }
   }

   IpcHandler {
      target: "volume"
      function toggle(): void {
         root.launcherOpen = false
         root.volumeOpen = !root.volumeOpen
      }
   }

   VolumePopup {
      open: root.volumeOpen
      onCloseRequested: root.volumeOpen = false
   }

   LazyLoader {
      active: root.launcherOpen

      PanelWindow {
         anchors.top: true
         implicitWidth: 600
         implicitHeight: 30
         color: "transparent"
         exclusiveZone: 0
         WlrLayershell.layer: WlrLayer.Overlay
         WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
         WlrLayershell.namespace: "launcher"

         Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            border.color: "#89b4fa"
            border.width: 0
            bottomLeftRadius: 14
            bottomRightRadius: 14

            TextInput {
               id: input
               anchors.fill: parent
               anchors.leftMargin: 18
               anchors.rightMargin: 18
               verticalAlignment: TextInput.AlignVCenter
               color: "#cdd6f4"
               selectionColor: "#89b4fa"
               font.pixelSize: 16
               clip: true

               Component.onCompleted: forceActiveFocus()

               onAccepted: {
                  const cmd = text.trim()
                  if (cmd !== "")
                     Quickshell.execDetached(["sh", "-c", cmd])
                  root.launcherOpen = false
               }

               Keys.onEscapePressed: root.launcherOpen = false
            }
         }
      }
   }
}
