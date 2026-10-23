# Generated from the immutable native release manifest. Do not edit checksums by hand.
# Source commit: 6ed1427f25bdfade4e588a04ce9498ba15fa8444
class UrNexus < Formula
  desc "Terminal coding agent with a bundled runtime and local-first provider support"
  homepage "https://github.com/Maitham16/UR"
  version "1.87.4"
  license :cannot_represent

  # Keep upstream native library IDs and resource-integrity hashes intact.
  preserve_rpath
  skip_clean "libexec"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      depends_on arch: :arm64
      url "https://github.com/Maitham16/UR/releases/download/v1.87.4/ur-1.87.4-darwin-arm64.tar.gz"
      sha256 "98ba84ef59cc21d8fb6006fcd58ae307a7c73ebfdd65491d42bc42465079f37c"
    end
    on_intel do
      depends_on arch: :x86_64
      url "https://github.com/Maitham16/UR/releases/download/v1.87.4/ur-1.87.4-darwin-x64.tar.gz"
      sha256 "180e1a6e871365b6adad5b0f1e6cfae9c00ecb10608da9626c4fa412ed133d07"
    end
  end

  on_linux do
    on_arm do
      depends_on arch: :arm64
      url "https://github.com/Maitham16/UR/releases/download/v1.87.4/ur-1.87.4-linux-arm64.tar.gz"
      sha256 "5987a35ac0f520090043a5aa1b2d979d155fe2adb39c13a495078676f0041158"
    end
    on_intel do
      depends_on arch: :x86_64
      url "https://github.com/Maitham16/UR/releases/download/v1.87.4/ur-1.87.4-linux-x64.tar.gz"
      sha256 "17375913c4ce0307ef8e015897d7c5822f47d2ccab82817213d49e050fd44b3b"
    end
  end

  def install
    if OS.linux?
      odie "UR requires system glibc 2.28 or newer" if OS::Linux::Glibc.system_version < Version.new("2.28")
      if Hardware::CPU.intel?
        features = Hardware::CPU.features
        required = %i[cx16 lahf_lm popcnt sse4_1 sse4_2 ssse3]
        unless (required - features).empty? && (features.include?(:pni) || features.include?(:sse3))
          odie "UR's image library requires an x86-64-v2 CPU, including SSE4.2"
        end
      end
    end
    libexec.install "ur", "resources"
    bin.install_symlink libexec/"ur"
  end

  def caveats
    <<~EOS
      UR includes its runtime; Node.js, npm, and Bun are not required.
      Choose a provider and model on the first run with: ur
      Manage this installation with: brew upgrade ur-nexus
      UR uses its upstream non-commercial license; see #{libexec}/resources/LICENSE.
      macOS 15+ is required. Linux qualification: Ubuntu 22.04 x64 and 24.04 ARM64
      with glibc; Linux x64 additionally requires an x86-64-v2 CPU.
    EOS
  end

  test do
    ENV["HOME"] = testpath.to_s
    ENV["UR_CONFIG_DIR"] = (testpath/"config").to_s
    ENV["UR_CODE_DISABLE_NONESSENTIAL_TRAFFIC"] = "1"
    ENV["DISABLE_TELEMETRY"] = "1"
    ENV["PATH"] = "/usr/bin:/bin"
    assert_equal "#{version} (UR-Nexus)", shell_output("#{bin}/ur --version").strip
    report = JSON.parse(shell_output("#{bin}/ur --ur-native-self-test"))
    assert_equal true, report["passed"]
  end
end
