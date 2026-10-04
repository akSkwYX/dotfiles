import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

LazyLoader {
   id: loader
   property bool open: false
   signal closeRequested()
   active: open

   PanelWindow {
      id: win

      property real volume: 0
      property bool muted: false
      readonly property string sink: "@DEFAULT_AUDIO_SINK@"
      readonly property real step: 0.05

      anchors.top: true
      implicitWidth: 400
      implicitHeight: 30
      color: "transparent"
      exclusiveZone: 0
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
      WlrLayershell.namespace: "volume"

      Process {
         command: ["wpctl", "get-volume", win.sink]
         running: true
         stdout: StdioCollector {
            onStreamFinished: {
               const m = text.match(/Volume:\s+([\d.]+)/)
               if (m) win.volume = parseFloat(m[1])
               win.muted = text.includes("[MUTED]")
            }
         }
      }

      function change(delta) {
         volume = Math.max(0, Math.min(1, Math.round((volume + delta) * 100) / 100))
         if (muted) {
            muted = false
            Quickshell.execDetached(["wpctl", "set-mute", sink, "0"])
         }
         Quickshell.execDetached(["wpctl", "set-volume", "-l", "1.0", sink, volume.toFixed(2)])
      }

      function toggleMute() {
         muted = !muted
         Quickshell.execDetached(["wpctl", "set-mute", sink, "toggle"])
      }

      Rectangle {
         anchors.fill: parent
         color: "#1e1e2e"
         bottomLeftRadius: 14
         bottomRightRadius: 14

         Item {
            anchors.fill: parent
            focus: true
            Component.onCompleted: forceActiveFocus()

            Keys.onPressed: (event) => {
               switch (event.key) {
                  case Qt.Key_K: win.change(win.step); break
                  case Qt.Key_J: win.change(-win.step); break
                  case Qt.Key_Space:
                     if (!event.isAutoRepeat) win.toggleMute()
                     break
                  case Qt.Key_Escape:
                  case Qt.Key_Q:
                  case Qt.Key_Return: loader.closeRequested(); break
                  default: return
               }
               event.accepted = true
            }

            Rectangle {
               id: track
               anchors.left: parent.left
               anchors.right: label.left
               anchors.leftMargin: 18
               anchors.rightMargin: 12
               anchors.verticalCenter: parent.verticalCenter
               height: 8
               radius: 4
               color: "#313244"

               Rectangle {
                  width: parent.width * win.volume
                  height: parent.height
                  radius: parent.radius
                  color: win.muted ? "#6c7086" : "#89b4fa"
                  Behavior on width { NumberAnimation {duration: 80} }
               }
            }

            Text {
               id: label
               anchors.right: parent.right
               anchors.rightMargin: 18
               anchors.verticalCenter: parent.verticalCenter
               width: 44
               horizontalAlignment: Text.AlignRight
               text: Math.round(win.volume * 100) + "%"
               color: win.muted ? "#6c7086" : "#89b4fa"
               font.pixelSize: 14
            }
         }
      }
   }
}
