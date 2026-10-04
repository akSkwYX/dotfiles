config.load_autoconfig(True)

config.bind("sl", "cmd-set-text -s :session-load")
config.bind(",d", "config-cycle colors.webpage.darkmode.enabled")

c.qt.args = [
    "disable-accelerated-video-decode"
]

c.url.start_pages = ["file:///home/skwyx/.config/qutebrowser/startpage/index.html"]
c.url.default_page = "file:///home/skwyx/.config/qutebrowser/startpage/index.html"

c.tabs.new_position.related = "next"
c.tabs.new_position.unrelated = "next"

c.content.blocking.method = "both"
c.content.autoplay = False

c.tabs.show = "multiple"
c.statusbar.show = "in-mode"

c.colors.webpage.darkmode.enabled = False
c.fonts.default_family = "JetBrains Mono"
c.fonts.default_size = "12pt"

c.colors.statusbar.insert.bg = "#40116e"
c.colors.statusbar.command.bg = "#40116e"
c.colors.completion.odd.bg = "#7a2bbf"
c.colors.completion.even.bg = "#9e4fde"
c.colors.completion.category.bg = "#40116e"
c.colors.completion.category.border.top = "#40116e"
c.colors.completion.category.border.bottom = "#40116e"
c.colors.completion.item.selected.bg = "#ff6d00"

c.colors.tabs.even.bg = "#40116e"
c.colors.tabs.odd.bg = "#40116e"
c.colors.tabs.selected.even.bg = "#7a2bbf"
c.colors.tabs.selected.odd.bg = "#7a2bbf"
