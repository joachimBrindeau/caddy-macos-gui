cask "caddy-gui" do
  version "1.0.0"
  sha256 "879301e6955581b7ab757336f9c8778f744e9d8ac2099f9e2dcf8a1df7e24ac9"

  url "https://github.com/joachimBrindeau/caddy-macos-gui/releases/download/v#{version}/Caddy.GUI_#{version}_aarch64.dmg"
  name "Caddy GUI"
  desc "A clean, modern GUI for managing Caddy server configurations on macOS"
  homepage "https://github.com/joachimBrindeau/caddy-macos-gui"

  depends_on macos: ">= :big_sur"

  app "Caddy GUI.app"

  # Post-install: Remove quarantine attributes automatically
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/Caddy GUI.app"],
                   sudo: false
  end

  # Uninstall: Clean up app data
  zap trash: [
    "~/Library/Application Support/com.joachim.caddy-gui",
    "~/Library/Preferences/com.joachim.caddy-gui.plist",
    "~/Library/Saved Application State/com.joachim.caddy-gui.savedState",
    "~/.caddy-gui",
  ]
end