cask "look" do
  owner = "kunkka19xx"
  repo = "look"
  app_name = "Look"
  release_tag_prefix = "v"
  release_asset_suffix = "macOS.zip"
  version "0.6.6"
  sha256 "b1cb8a5d9753fb92241075aa31c18975ca96a5735b28d9732b72128d2a1ce808"
  url "https://github.com/#{owner}/#{repo}/releases/download/#{release_tag_prefix}#{version}/#{app_name}-#{version}-#{release_asset_suffix}"
  name repo
  desc "Keyboard-first local launcher for macOS"
  homepage "https://github.com/#{owner}/#{repo}"
  app "#{app_name}.app"
  binary "#{app_name}.app/Contents/MacOS/Look", target: "lookapp"
end
