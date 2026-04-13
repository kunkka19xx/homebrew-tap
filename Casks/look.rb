cask "look" do
  owner = "kunkka19xx"
  repo = "look"
  app_name = "Look"
  release_tag_prefix = "v"
  release_asset_suffix = "macOS.zip"
  version "0.3.1"
  sha256 "f78e3e49d0c1f2ec59d95da69c89a4c76ee91e1cf8014b666d339fecfd6d9566"
  url "https://github.com/#{owner}/#{repo}/releases/download/#{release_tag_prefix}#{version}/#{app_name}-#{version}-#{release_asset_suffix}"
  name repo
  desc "Keyboard-first local launcher for macOS"
  homepage "https://github.com/#{owner}/#{repo}"
  app "#{app_name}.app"
  binary "#{app_name}.app/Contents/MacOS/Look", target: "lookapp"
end
