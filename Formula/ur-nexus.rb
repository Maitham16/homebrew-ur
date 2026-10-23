# Generated from the immutable native release manifest. Do not edit checksums by hand.
# Source commit: f683cd44a135b65062fa1871c7a6539c264c2da4
class UrNexus < Formula
  desc "Terminal coding agent with a bundled runtime and local-first provider support"
  homepage "https://github.com/Maitham16/UR"
  version "1.87.3"
  license :cannot_represent

  # Keep upstream native library IDs and resource-integrity hashes intact.
  preserve_rpath
  skip_clean "libexec"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      depends_on arch: :arm64
      url "https://github.com/Maitham16/UR/releases/download/v1.87.3/ur-1.87.3-darwin-arm64.tar.gz"
      sha256 "534c0cf76ce154c536f99a671aaaecfe6b47ce06067df22207b4fd133ee33376"
    end
    on_intel do
      depends_on arch: :x86_64
      url "https://github.com/Maitham16/UR/releases/download/v1.87.3/ur-1.87.3-darwin-x64.tar.gz"
      sha256 "5deb8012fb3eeacead75dffa4a78d168cb5937c5006655a41d735b3c3360d613"
    end
  end

  on_linux do
    on_arm do
      depends_on arch: :arm64
      url "https://github.com/Maitham16/UR/releases/download/v1.87.3/ur-1.87.3-linux-arm64.tar.gz"
      sha256 "51873c365ba46b0d300d4a5f11722fc3ebb80622cbfb5907efb9e57e14e1fdb0"
    end
    on_intel do
      depends_on arch: :x86_64
      url "https://github.com/Maitham16/UR/releases/download/v1.87.3/ur-1.87.3-linux-x64.tar.gz"
      sha256 "64468f56479a95f09e76ce2a3be56a0ba50faa9d402d61fa184ef239aad19a01"
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
