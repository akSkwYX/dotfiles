import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

LazyLoader {
   id: launcher
   property bool open: false
   signal closeRequested()
   active: open

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
               launcher.closeRequested()
            }

            Keys.onEscapePressed: launcher.closeRequested()
         }
      }
   }
}
