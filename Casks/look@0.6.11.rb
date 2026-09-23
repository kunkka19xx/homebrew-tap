cask "look@0.6.11" do
  owner = "kunkka19xx"
  repo = "look"
  app_name = "Look"
  release_tag_prefix = "v"
  release_asset_suffix = "macOS.zip"

  version "0.6.11"
  sha256 "cd2c10200b0f2a5e68086ad5a2bae27d070d82f0faf59c15a68cf489f385b50e"

  url "https://github.com/#{owner}/#{repo}/releases/download/#{release_tag_prefix}#{version}/#{app_name}-#{version}-#{release_asset_suffix}"
  name "look"
  desc "Keyboard-first local launcher for macOS"
  homepage "https://github.com/#{owner}/#{repo}"

  livecheck do
    skip "Versioned cask"
  end

  conflicts_with cask: ["look", "look@0.6.12", "look@0.6.13", "look@0.7.0"]
  app "#{app_name}.app"
end
