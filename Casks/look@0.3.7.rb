cask "look@0.3.7" do
  owner = "kunkka19xx"
  repo = "look"
  app_name = "Look"
  release_tag_prefix = "v"
  release_asset_suffix = "macOS.zip"

  version "0.3.7"
  sha256 "927ccba21190c02e6a7c46b2ec57fd145361db3f1166d1ed060c578152d8585c"

  url "https://github.com/#{owner}/#{repo}/releases/download/#{release_tag_prefix}#{version}/#{app_name}-#{version}-#{release_asset_suffix}"
  name "look"
  desc "Keyboard-first local launcher for macOS"
  homepage "https://github.com/#{owner}/#{repo}"

  livecheck do
    skip "Versioned cask"
  end

  conflicts_with cask: ["look", "look@0.1.1", "look@0.1.2", "look@0.1.3", "look@0.1.4", "look@0.1.5", "look@0.1.6", "look@0.1.7", "look@0.1.8", "look@0.1.9", "look@0.1", "look@0.2.0", "look@0.2.1", "look@0.2.2", "look@0.2.3", "look@0.3.0", "look@0.3.1", "look@0.3.2", "look@0.3.3", "look@0.3.4", "look@0.3.5", "look@0.3.6", "look@2.0.4", "look@2.0.5"]
  app "#{app_name}.app"
end
