cask "look" do
  owner = "kunkka19xx"
  repo = "look"
  app_name = "Look"
  release_tag_prefix = "v"
  release_asset_suffix = "macOS.zip"
  version "2.0.5"
  sha256 "475f9d9e71ebc8541a13aeea90eedb0c8d3f4a6f0968b75672394480abf21ee6"
  url "https://github.com/#{owner}/#{repo}/releases/download/#{release_tag_prefix}#{version}/#{app_name}-#{version}-#{release_asset_suffix}"
  name repo
  desc "Keyboard-first local launcher for macOS"
  homepage "https://github.com/#{owner}/#{repo}"
  app "#{app_name}.app"
  binary "#{app_name}.app/Contents/MacOS/Look", target: "lookapp"
end
