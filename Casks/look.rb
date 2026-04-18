cask "look" do
  owner = "kunkka19xx"
  repo = "look"
  app_name = "Look"
  release_tag_prefix = "v"
  release_asset_suffix = "macOS.zip"
  version "0.3.3"
  sha256 "a73dd0e890f040b6a6ffbffbe786e8c6490b3a811c6ef88f478ddbb7fa8658be"
  url "https://github.com/#{owner}/#{repo}/releases/download/#{release_tag_prefix}#{version}/#{app_name}-#{version}-#{release_asset_suffix}"
  name repo
  desc "Keyboard-first local launcher for macOS"
  homepage "https://github.com/#{owner}/#{repo}"
  app "#{app_name}.app"
  binary "#{app_name}.app/Contents/MacOS/Look", target: "lookapp"
end
