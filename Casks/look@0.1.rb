cask "look@0.1" do
  owner = "kunkka19xx"
  repo = "look"
  app_name = "Look"
  release_tag_prefix = "v"
  release_asset_suffix = "macOS.zip"

  version "0.1.0"
  sha256 "d50740f73c3610cb783c6e54f6079f71a553d24254409e4d92c42df431cc7d85"

  url "https://github.com/#{owner}/#{repo}/releases/download/#{release_tag_prefix}#{version}/#{app_name}-#{version}-#{release_asset_suffix}"
  name "look"
  desc "Keyboard-first local launcher for macOS"
  homepage "https://github.com/#{owner}/#{repo}"

  livecheck do
    skip "Versioned cask"
  end

  conflicts_with cask: "look"
  app "#{app_name}.app"
end
