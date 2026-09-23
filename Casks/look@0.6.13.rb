cask "look@0.6.13" do
  owner = "kunkka19xx"
  repo = "look"
  app_name = "Look"
  release_tag_prefix = "v"
  release_asset_suffix = "macOS.zip"

  version "0.6.13"
  sha256 "9906207a56ae0e14e7a1055088e81595009bd0de133f0c2e369db3b8773d0b92"

  url "https://github.com/#{owner}/#{repo}/releases/download/#{release_tag_prefix}#{version}/#{app_name}-#{version}-#{release_asset_suffix}"
  name "look"
  desc "Keyboard-first local launcher for macOS"
  homepage "https://github.com/#{owner}/#{repo}"

  livecheck do
    skip "Versioned cask"
  end

  conflicts_with cask: ["look", "look@0.6.11", "look@0.6.12", "look@0.7.0"]
  app "#{app_name}.app"
end
