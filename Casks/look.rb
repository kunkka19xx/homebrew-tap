cask "look" do
  version "0.7.0"
  sha256 "eca3f75f4a24363184fab0361993149605fcd579f68e27ddfe95331c94336c2c"

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
