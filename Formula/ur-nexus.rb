# Generated from the immutable native release manifest. Do not edit checksums by hand.
# Source commit: e81469b4554d5c209081df72d0350ffe8e59eca7
class UrNexus < Formula
  desc "Terminal coding agent with a bundled runtime and local-first provider support"
  homepage "https://github.com/Maitham16/UR"
  version "1.86.2"
  license :cannot_represent

  # Keep upstream native library IDs and resource-integrity hashes intact.
  preserve_rpath
  skip_clean "libexec"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      depends_on arch: :arm64
      url "https://github.com/Maitham16/UR/releases/download/v1.86.2/ur-1.86.2-darwin-arm64.tar.gz"
      sha256 "6688e46c5d8649243d3aca8277955f08fcba5e410980ec66eb92b85d2cf663aa"
    end
    on_intel do
      depends_on arch: :x86_64
      url "https://github.com/Maitham16/UR/releases/download/v1.86.2/ur-1.86.2-darwin-x64.tar.gz"
      sha256 "87abc3c19a748722d0942e467c49dd488efb2c819af3a1bebc4380ba63a2f3fc"
    end
  end

  on_linux do
    on_arm do
      depends_on arch: :arm64
      url "https://github.com/Maitham16/UR/releases/download/v1.86.2/ur-1.86.2-linux-arm64.tar.gz"
      sha256 "d5b81f07c2b29b28ac79ab78f16fa3bfd1da04787195065f3d369f680527ff00"
    end
    on_intel do
      depends_on arch: :x86_64
      url "https://github.com/Maitham16/UR/releases/download/v1.86.2/ur-1.86.2-linux-x64.tar.gz"
      sha256 "03cb8d1d7fc1724667f0446632ddffed9ffc4f8aa5cd31e8eab60b7f34e79b04"
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
