cask "look@0.1.4" do
  owner = "kunkka19xx"
  repo = "look"
  app_name = "Look"
  release_tag_prefix = "v"
  release_asset_suffix = "macOS.zip"

  version "0.1.4"
  sha256 "f43a3e01e4f44e94f9efbfa2bfa964143dfd76d4ecd4d1f39d0677305c1936e0"

  url "https://github.com/#{owner}/#{repo}/releases/download/#{release_tag_prefix}#{version}/#{app_name}-#{version}-#{release_asset_suffix}"
  name "look"
  desc "Keyboard-first local launcher for macOS"
  homepage "https://github.com/#{owner}/#{repo}"

  livecheck do
    skip "Versioned cask"
  end

  conflicts_with cask: ["look", "look@0.1", "look@0.1.1", "look@0.1.2", "look@0.1.3"]
  app "#{app_name}.app"
end
