import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

LazyLoader {
   id: loader
   property bool open: false
   signal closeRequested()
   active: open

   property string placeholder: "Search..."
   property string newLabel: "New"
   property var statusCommand: []
   property var rescanCommand: []
   property string connectScript: ""
   property var parse: (text) => ({ items: [], powered: true, blocked: false })
   property var needsSecret: (item) => false
   property var powerArgv: (on) => []
   property var blockArgv: (block) => []

   PanelWindow {
      id: win

      property string mode: "normal"
      property string query: ""
      property bool expanded: false
      property bool powered: true
      property bool blocked: false
      property var entries: []
      property var rows: []
      property int sel: 0
      property var target: null

      readonly property int rowH: 34
      readonly property int barH: 52
      readonly property color fg: powered ? "#cdd6f4" : "#6c7086"
      readonly property color accent: powered ? "#89b4fa" : "#6c7086"

      anchors.top: true
      implicitWidth: 440
      implicitHeight: barH + list.height + (mode === "secret" ? barH : 0) + 6
      color: "transparent"
      exclusiveZone: 0
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
      WlrLayershell.namespace: "listpopup"

      function cmp(a, b) {
         if (a.active !== b.active) return a.active ? -1 : 1
         if (a.known !== b.known) return a.known ? -1 : 1
         return (b.rank || 0) - (a.rank || 0)
      }

      function fuzzy(q, text) {
         const t = text.toLowerCase(), s = q.toLowerCase()
         let ti = 0, prev = -2, score = 0
         for (let qi = 0; qi < s.length; qi++) {
            const idx = t.indexOf(s[qi], ti)
            if (idx < 0) return -1
            score += 1
            if (idx === prev + 1) score += 3
            if (idx === 0 || " -_.".indexOf(t[idx - 1]) >= 0) score += 2
            score -= (idx - ti) * 0.1
            prev = idx
            ti = idx + 1
         }
         return score - t.length * 0.01
      }

      function keyOf(r) {
         return r ? (r.kind === "item" ? r.e.id : "") : null
      }

      function rebuild() {
         let list
         if (query !== "") {
            list = entries.map(e => ({ e: e, s: fuzzy(query, e.label) }))
                          .filter(x => x.s >= 0)
                          .sort((a, b) => b.s - a.s)
                          .map(x => x.e)
         } else {
            list = entries.filter(e => expanded || e.known || e.active).sort(cmp)
         }
         const out = list.map(e => ({kind: "item", e: e}))
         if (query === "") out.push ({kind: "button" })
         rows = out
         sel = Math.max(0, Math.min(sel, rows.length - 1))
      }

      function apply(text) {
         const k = keyOf(rows[sel])
         const r = loader.parse(text)
         powered = r.powered
         blocked = r.blocked
         entries = r.powered ? r.items : []
         rebuild()
         if (k !== null) {
            const i = rows.findIndex(x => keyOf(x) === k)
            if (i >= 0) sel = i
         }
      }

      function setMode(m) {
         mode = m
         if (m == "insert") search.forceActiveFocus()
         else if (m == "secret") { pw.text = ""; pw.forceActiveFocus() }
         else keys.forceActiveFocus()
      }

      function move(d) {
         sel = Math.max(0, Math.min(rows.length - 1, sel + d))
      }

      function activate(row) {
         if (!row || !powered) return
         if (row.kind === "button") {
            expanded = !expanded
            rebuild()
            sel = rows.length - 1
            return
         }
         const e = row.e
         if (e.active) return
         if (loader.needsSecret(e)) { target = e; setMode("secret"); return }
         connect(e, "")
      }

      function connect(e, secret) {
         Quickshell.execDetached(["sh", "-c", loader.connectScript, "sh", e.known ? "up" : "new", e.id, secret])
         loader.closeRequested()
      }

      function togglePower() {
         powered = !powered
         Quickshell.execDetached(loader.powerArgv(powered))
         if (!powered) entries = []
         rebuild()
         refresh.restart()
      }

      function toggleBlock() {
         blocked = !blocked
         Quickshell.execDetached(loader.blockArgv(blocked))
         refresh.restart()
      }

      Process {
         id: scanner
         command: loader.rescanCommand
         running: loader.rescanCommand.length > 0
      }
      Component.onDestruction: scanner.running = false

      Process {
         id: reader
         command: loader.statusCommand
         running: true
         stdout: StdioCollector { onStreamFinished: win.apply(text) }
      }

      Timer {
         id: refresh
         interval: 3000
         repeat: true
         running: true
         onTriggered: if (!reader.running) reader.running = true
      }

      Rectangle {
         anchors.fill: parent
         color: "#1e1e2e"
         bottomLeftRadius: 14
         bottomRightRadius: 14

         Item {
            id: keys
            anchors.fill: parent
            focus: true
            Component.onCompleted: forceActiveFocus()

            Keys.onPressed: (e) => {
               switch(e.key) {
                  case Qt.Key_J: win.move(1); break
                  case Qt.Key_K: win.move(-1); break
                  case Qt.Key_L:
                  case Qt.Key_Return: win.activate(win.rows[win.sel]); break
                  case Qt.Key_H:
                     if (win.expanded) { win.expanded = false; win.rebuild() }
                     break
                  case Qt.Key_I: win.setMode("insert"); break
                  case Qt.Key_Space:
                     if (e.isAutoRepeat) break
                     if (e.modifiers & Qt.ShiftModifier) win.toggleBlock()
                     else win.togglepower()
                     break
                  case Qt.Key_Escape:
                     if (win.query !== "") search.text = ""
                     else loader.closeRequested()
                     break
                  default: return
               }
               e.accepted = true
            }
         }

         Column {
            anchors.fill: parent

            Item {
               width: parent.width
               height: win.barH

               TextInput {
                  id: search
                  anchors.left: parent.left
                  anchors.right: badge.left
                  anchors.leftMargin: 18
                  anchors.rightMargin: 12
                  anchors.verticalCenter: parent.verticalCenter
                  color: win.fg
                  selectionColor: win.accent
                  font.pixelSize: 16
                  clip: true

                  onTextChanged: { win.query = text; win.sel = 0; win.rebuild() }
                  Keys.onEscapePressed: win.setMode("normal")
                  Keys.onReturnPressed: { win.sel = 0; win.activate(win.rows[0]) }

                  Text {
                     visible: search.text === ""
                     anchors.verticalCenter: parent.verticalCenter
                     text: win.mode === "insert" ? loader.placeholder : "i to search"
                     color: "#6c7086"
                     font: search.font
                  }
               }

               Text {
                  id: badge
                  anchors.right: parent.right
                  anchors.rightMargin: 18
                  anchors.verticalCenter: parent.verticalCenter
                  text: (win.blocked ? "✈ " : "") + (win.powered ? "" : "off")
                  color: win.blocked ? "#f38ba8" : "#6c7086"
                  font.pixelSize: 14
               }
            }

            ListView {
               id: list
               width: parent.width
               height: Math.min(win.rows.length, 8) * win.rowH
               clip: true
               interactive: false
               model: win.rows
               currentIndex: win.sel
               onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

               delegate: Rectangle {
                  required property var modelData
                  required property int index
                  readonly property bool isItem: modelData.kind === "item"

                  width: list.width
                  height: win.rowH
                  color: index === win.sel ? "#313244" : "transparent"

                  Rectangle {
                     visible: index === win.sel
                     width: 3
                     height: parent.height - 12
                     anchors.verticalCenter: parent.verticalCenter
                     color: win.accent
                  }

                  Text {
                     anchors.left: parent.left
                     anchors.right: detail.left
                     anchors.leftMargin: 18
                     anchors.rightMargin: 8
                     anchors.verticalCenter: parent.verticalCenter
                     elide: Text.ElideRight
                     font.pixelSize: 15
                     font.bold: isItem && modelData.e.active
                     color: isItem && modelData.e.active ? win.accent : win.fg
                     text: isItem ? modelData.e.label
                                  : (win.expanded ? "- Less" : "+ " + loader.newLabel)
                  }

                  Text {
                     id: detail
                     anchors.right: parent.right
                     anchors.rightMargin: 18
                     anchors.verticalCenter: parent.verticalCenter
                     font.pixelSize: 12
                     color: "#6c7086"
                     text: isItem ? modelData.e.detail : ""
                  }
               }
            }

            Item {
               visible: win.mode === "secret"
               width: parent.width
               height: win.barH
               
               Rectangle {
                  x: 18
                  width: parent.width - 36
                  height: 1
                  color: "#313244"
               }

               TextInput {
                  id: pw
                  anchors.fill: parent
                  anchors.leftMargin: 18
                  anchors.rightMargin: 18
                  verticalAlignment: TextInput.AlignVCenter
                  echoMode: TextInput.Password
                  color: win.fg
                  font.pixelSize: 16
                  Keys.onEscapePressed: win.setMode("normal")
                  Keys.onReturnPressed: win.connect(win.target, text)

                  Text {
                     visible: pw.text === ""
                     anchors.verticalCenter: parent.verticalCenter
                     text: win.target ? "Password for " + win.target.label : ""
                     color: "#6c7086"
                     font: pw.font
                  }
               }
            }
         }
      }
   }
}
