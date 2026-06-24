cask "look" do
  owner = "kunkka19xx"
  repo = "look"
  app_name = "Look"
  release_tag_prefix = "v"
  release_asset_suffix = "macOS.zip"
  version "0.6.5"
  sha256 "f7118087edee18900d93c3436364c5cee2ea5eef394d32bc4d6c4630134ac1ea"
  url "https://github.com/#{owner}/#{repo}/releases/download/#{release_tag_prefix}#{version}/#{app_name}-#{version}-#{release_asset_suffix}"
  name repo
  desc "Keyboard-first local launcher for macOS"
  homepage "https://github.com/#{owner}/#{repo}"
  app "#{app_name}.app"
  binary "#{app_name}.app/Contents/MacOS/Look", target: "lookapp"
end
