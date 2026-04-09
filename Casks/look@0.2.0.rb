cask "look@0.2.0" do
  owner = "kunkka19xx"
  repo = "look"
  app_name = "Look"
  release_tag_prefix = "v"
  release_asset_suffix = "macOS.zip"

  version "0.2.0"
  sha256 "6dc6469f2ff4d3b433f7efc94a8fdbc2f776d4ae31e712149c9cefd691b96182"

  url "https://github.com/#{owner}/#{repo}/releases/download/#{release_tag_prefix}#{version}/#{app_name}-#{version}-#{release_asset_suffix}"
  name "look"
  desc "Keyboard-first local launcher for macOS"
  homepage "https://github.com/#{owner}/#{repo}"

  livecheck do
    skip "Versioned cask"
  end

  conflicts_with cask: ["look", "look@0.1.1", "look@0.1.2", "look@0.1.3", "look@0.1.4", "look@0.1.5", "look@0.1.6", "look@0.1.7", "look@0.1.8", "look@0.1.9", "look@0.1"]
  app "#{app_name}.app"
end
