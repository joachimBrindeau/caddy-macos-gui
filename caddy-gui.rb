cask "caddy-gui" do
  version "1.0.0"
  sha256 "772a5b2dba8110d5aabbc37e4f2aeac5864e976f5ed3d2cc89218871251055c1"

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