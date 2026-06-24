cask "look@0.6.4" do
  owner = "kunkka19xx"
  repo = "look"
  app_name = "Look"
  release_tag_prefix = "v"
  release_asset_suffix = "macOS.zip"

  version "0.6.4"
  sha256 "96686a89a02671f2d2dd41c92423fd4e981379a22aa20e1a02d0d6cc0fd2ac44"

  url "https://github.com/#{owner}/#{repo}/releases/download/#{release_tag_prefix}#{version}/#{app_name}-#{version}-#{release_asset_suffix}"
  name "look"
  desc "Keyboard-first local launcher for macOS"
  homepage "https://github.com/#{owner}/#{repo}"

  livecheck do
    skip "Versioned cask"
  end

  conflicts_with cask: ["look", "look@0.1.1", "look@0.1.2", "look@0.1.3", "look@0.1.4", "look@0.1.5", "look@0.1.6", "look@0.1.7", "look@0.1.8", "look@0.1.9", "look@0.1", "look@0.2.0", "look@0.2.1", "look@0.2.2", "look@0.2.3", "look@0.3.0", "look@0.3.1", "look@0.3.2", "look@0.3.3", "look@0.3.4", "look@0.3.5", "look@0.3.6", "look@0.3.7", "look@0.3.8", "look@0.3.9", "look@0.4.1", "look@0.4.2", "look@0.4.3", "look@0.4.4", "look@0.5.3", "look@0.5.7", "look@0.5.8", "look@0.6.0", "look@0.6.2", "look@0.6.3", "look@2.0.4", "look@2.0.5"]
  app "#{app_name}.app"
end
