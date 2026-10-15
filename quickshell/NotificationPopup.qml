import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick

Scope {
   id: root

   NotificationServer {
      id: server
      keepOnReload: false
      bodySupported: true
      bodyMarkupSupported: false
      actionsSupported: false
      imageSupported: false
      onNotification: (n) => { n.tracked = true }
   }

   IpcHandler {
      target: "notifications"

      function clearOldest(): void {
         for (let i = list.count - 1; i >= 0; i--) {
            const it = list.itemAtIndex(i)
            if (it && !it.leaving) { it.leave(true); return }
         }
      }

      function clearAll(): void {
         for (let i = 0; i < list.count; i++) {
            const it = list.itemAtIndex(i)
            if (it && !it.leaving) it.leave(true)
         }
      }
   }

   PanelWindow {
      id: win

      anchors.top: true
      anchors.right: true
      anchors.bottom: true
      implicitWidth: 380
      visible: list.count >= 0
      color: "transparent"
      exclusiveZone: 0
      mask: Region { item: stack }
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "notifications"

      Item {
         id: stack
         anchors.top: parent.top
         anchors.right: parent.right
         width: parent.width
         height: list.contentHeight
         clip: true

         Behavior on height {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
         }

         Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            bottomLeftRadius: 14
         }

         ListView {
            id: list
            width: parent.width
            height: contentHeight
            interactive: false

            model: ScriptModel {
               values: Array.from(server.trackedNotifications.values).reverse()
            }

            add: Transition {
               NumberAnimation {
                  property: "x"; from: list.width
                  duration: 220; easing.type: Easing.OutCubic
               }
            }

            displaced: Transition {
               NumberAnimation {
                  property: "y"
                  duration: 220; easing.type: Easing.OutCubic
               }
            }
            delegate: Item {
               id: card
               required property var modelData

               property bool leaving: false
               property bool byUser: false

               readonly property int timeoutMs: {
                  const t = modelData.expireTimeout
                  if (t > 0) return t * 1000
                  return modelData.urgency === NotificationUrgency.Critical ? 10000 : 5000
               }

               readonly property color accent:
                  modelData.urgency === NotificationUrgency.Critical ? "#f38ba8"
                  : modelData.urgency === NotificationUrgency.Low ? "#6c7086"
                  : "#89b4fa"

               width: list.width
               height: body.height

               function leave(manual) {
                  if (leaving) return
                  leaving = true
                  byUser = manual
                  exit.start()
               }

               Timer {
                  interval: card.timeoutMs
                  running: !card.leaving
                  onTriggered: card.leave(false)
               }

               NumberAnimation {
                  id: exit
                  target: body
                  property: "x"
                  to: card.width + 20
                  duration: 180
                  easing.type: Easing.InCubic
                  onFinished: {
                     if (card.byUser) card.modelData.dismiss()
                     else card.modelData.expire()
                  }
               }

               Item {
                  id: body
                  width: parent.width
                  height: col.implicitHeight + 24

                  Rectangle {
                     width: 3
                     height: parent.height - 20
                     anchors.verticalCenter: parent.verticalCenter
                     color: card.accent
                  }

                  Column {
                     id: col
                     x: 18
                     y: 12
                     width: parent.width - 36
                     spacing: 2

                     Text {
                        width: col.width
                        text: card.modelData.summary
                        color: "#cdd6f4"
                        font.pixelSize: 14
                        font.bold: true
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                     }
                     Text {
                        width: col.width
                        text: card.modelData.body
                        visible: text !== ""
                        color: "#bac2de"
                        font.pixelSize: 13
                        wrapMode: Text.Wrap
                        maximumLineCount: 4
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                     }
                  }

                  Rectangle {
                     anchors.bottom: parent.bottom
                     x: 18
                     width: parent.width - 36
                     height: 1
                     color: "#313244"
                  }
               }
            }
         }
      }
   }
}
