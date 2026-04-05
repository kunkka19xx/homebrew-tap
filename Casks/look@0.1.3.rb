cask "look@0.1.3" do
  owner = "kunkka19xx"
  repo = "look"
  app_name = "Look"
  release_tag_prefix = "v"
  release_asset_suffix = "macOS.zip"

  version "0.1.3"
  sha256 "b248c0debf414928271c976ba1870bc7a10ccf563ab02df1b62a630949b2dc27"

  url "https://github.com/#{owner}/#{repo}/releases/download/#{release_tag_prefix}#{version}/#{app_name}-#{version}-#{release_asset_suffix}"
  name "look"
  desc "Keyboard-first local launcher for macOS"
  homepage "https://github.com/#{owner}/#{repo}"

  livecheck do
    skip "Versioned cask"
  end

  conflicts_with cask: ["look", "look@0.1", "look@0.1.1", "look@0.1.2"]
  app "#{app_name}.app"
end
