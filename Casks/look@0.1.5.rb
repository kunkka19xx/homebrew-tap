cask "look@0.1.5" do
  owner = "kunkka19xx"
  repo = "look"
  app_name = "Look"
  release_tag_prefix = "v"
  release_asset_suffix = "macOS.zip"

  version "0.1.5"
  sha256 "f8141eac494c837c52439050d7fdc79d1570d2de76e84753b31b57fee6c8ca93"

  url "https://github.com/#{owner}/#{repo}/releases/download/#{release_tag_prefix}#{version}/#{app_name}-#{version}-#{release_asset_suffix}"
  name "look"
  desc "Keyboard-first local launcher for macOS"
  homepage "https://github.com/#{owner}/#{repo}"

  livecheck do
    skip "Versioned cask"
  end

  conflicts_with cask: ["look", "look@0.1", "look@0.1.1", "look@0.1.2", "look@0.1.3", "look@0.1.4"]
  app "#{app_name}.app"
end
