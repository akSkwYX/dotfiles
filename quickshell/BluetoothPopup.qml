import QtQuick

ListPopup {
   placeholder: "Search devices…"
   newLabel: "New device"

   statusCommand: ["sh", "-c",
      "bluetoothctl devices Paired; echo @@@;" +
      "bluetoothctl devices; echo @@@;" +
      "bluetoothctl show; echo @@@;" +
      "bluetoothctl devices Connected; echo @@@;" +
      "rfkill list bluetooth"]
   rescanCommand: ["bluetoothctl", "--timeout", "120", "scan", "on"]

   powerArgv: (on) => ["bluetoothctl", "power", on ? "on" : "off"]
   blockArgv: (b) => ["rfkill", b ? "block" : "unblock", "bluetooth"]

   parse: (text) => {
      const devs = (s) => {
         const m = {}
         for (const l of (s || "").split("\n")) {
            const r = l.match(/^Device\s+(\S+)\s+(.*)$/)
            if (r) m[r[1]] = r[2]
         }
         return m
      }
      const p = text.split("@@@\n")
      const paired = devs(p[0]), all = devs(p[1]), conn = devs(p[3])
      const unnamed = /^([0-9A-F]{2}-){5}[0-9A-F]{2}$/i

      return {
         items: Object.keys(all)
            .filter(mac => mac in paired || !unnamed.test(all[mac]))
            .map(mac => ({
               id: mac, label: all[mac],
               detail: (mac in conn ? "connected  " : "") + mac,
               active: mac in conn, known: mac in paired, secure: false, rank: 0
            })),
         powered: /Powered:\s+yes/.test(p[2] || ""),
         blocked: (p[4] || "").indexOf("Soft blocked: yes") >= 0
      }
   }
   connectScript: `
mode=$1; mac=$2
notify-send -a quickshell -u low "Bluetooth" "Connecting..."
if [ "$mode" = new ]; then
  out=$(bluetoothctl --timeout 20 pair "$mac" 2>&1) || {
    notify-send -u critical -a quickshell "Bluetooth: pairing failed" "$out"; exit 1; }
  bluetoothctl trust "$mac" >/dev/null 2>&1
fi
out=$(bluetoothctl --timeout 15 connect "$mac" 2>&1)
case "$out" in
  *"Connection successful"*) notify-send -a quickshell "Bluetooth" "Connected" ;;
  *) notify-send -u critical -a quickshell "Bluetooth: connection failed" "$out" ;;
esac
`
}
