import QtQuick

ListPopup {
   placeholder: "Search wifi..."
   newLabel: "New wifi"

   statusCommand: ["sh", "-c",
      "nmcli -t -f NAME,TYPE connection show; echo @@@;" +
      "nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list --rescan no; echo @@@;" +
      "nmcli radio wifi; echo @@@;" +
      "rfkill list wifi"
   ]
   rescanCommand: ["nmcli", "dev", "wifi", "rescan"]

   needsSecret: (e) => !e.known && e.secure
   powerArgv: (on) => ["nmcli", "radio", "wifi", on ? "on" : "off"]
   blockArgv: (b) => ["rfkill", b ? "block" : "unblock", "wifi"]

   parse: (text) => {
      const split = (line) => {
         const out = []; let cur = ""
         for (let i = 0; i < line.length; i++) {
            const c = line[i]
            if (c === "\\" && i + 1 < line.length) cur += line[++i]
            else if (c === ":") { out.push(cur); cur = "" }
            else cur += c
         }
         out.push(cur)
         return out
      }

      const p = text.split("@@@\n")
      const known = []
      for (const l of (p[0] || "").split("\n")) {
         if (!l) continue
         const f = split(l)
         if (f[1] === "802-11-wireless") known[f[0]] = true
      }

      const best = {}
      for (const l of (p[1] || "").split("\n")) {
         if (!l) continue
         const f = split(l)
         const ssid = f[1]
         if (!ssid) continue
         const signal = parseInt(f[2]) || 0
         const sec = (f[3] && f[3] !== "--") ? f[3] : ""
         const e = {
            id: ssid, label: ssid, active: f[0] === "*", known: !!known[ssid],
            secure: sec !== "", rank: signal,
            detail: (f[0] === "*" ? "connected " : "") + sec + " " + signal + "%"
         }
         const old = best[ssid]
         if (!old || e.active || (!old.active && e.rank > old.rank)) best[ssid] = e
      }

      return {
         items: Object.values(best),
         powered: (p[2] || "").trim() === "enabled",
         blocked: (p[3] || "").indexOf("Soft blocked: yes") >= 0
      }
   }

   connectScript: `
mode=$1; ssid=$2; pass=$3
notify-send -a quickshell -u low "Wi-Fi" "Connecting to $ssid..."
if [ "$mode" = up ]; then
   out=$(nmcli -w 20 connection up id "$ssid" 2>&1); rc=$?
elif [ -n "$pass" ]; then
   out=$(nmcli -w 20 dev wifi connect "$ssid" password "$pass" 2>&1); rc=$?
else
   out=$(nmcli -w 20 dev wifi connect "$ssid" 2>&1); rc=$?
fi
if [ $rc -eq 0 ]; then
   notify-send -a quickshell "Wi-Fi" "Connected to $ssid"
else
   [ "$mode" = new ] && nmcli connection delete id "$ssid" >/dev/null 2>&1
   case $out in
      *"Secrets where required"*|*"4-way"*) msg="Incorrect password" ;;
      *) msg="$out"
   esac
   notify-send -u critical -a quickshell "Wi-Fi: could not connect to $ssid" "$msg"
fi
`
}
