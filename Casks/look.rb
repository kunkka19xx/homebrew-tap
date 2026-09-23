cask "look" do
  version "0.6.13"
  sha256 "9906207a56ae0e14e7a1055088e81595009bd0de133f0c2e369db3b8773d0b92"

  url "https://github.com/kunkka19xx/look/releases/download/v#{version}/Look-#{version}-macOS.zip"
  name "Look"
  desc "Keyboard-first local launcher"
  homepage "https://github.com/kunkka19xx/look"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sequoia

  app "Look.app"
  binary "#{appdir}/Look.app/Contents/MacOS/Look", target: "lookapp"

  zap trash: [
    "~/.look",
    "~/Library/Application Support/Look",
    "~/Library/Caches/noah-code.Look",
    "~/Library/HTTPStorages/noah-code.Look",
    "~/Library/HTTPStorages/noah-code.Look.binarycookies",
    "~/Library/Preferences/noah-code.Look.plist",
  ]
end
