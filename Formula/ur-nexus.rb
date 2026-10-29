# Generated from the immutable native release manifest. Do not edit checksums by hand.
# Source commit: d6df0ee4b85c8f751da37ac010ea1091c149360e
class UrNexus < Formula
  desc "Terminal coding agent with a bundled runtime and local-first provider support"
  homepage "https://github.com/Maitham16/UR"
  version "1.87.5"
  license :cannot_represent

  # Keep upstream native library IDs and resource-integrity hashes intact.
  preserve_rpath
  skip_clean "libexec"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      depends_on arch: :arm64
      url "https://github.com/Maitham16/UR/releases/download/v1.87.5/ur-1.87.5-darwin-arm64.tar.gz"
      sha256 "11001f0c59196cdd75a9a22ea167e92bee8dafa651526759d86094a795090970"
    end
    on_intel do
      depends_on arch: :x86_64
      url "https://github.com/Maitham16/UR/releases/download/v1.87.5/ur-1.87.5-darwin-x64.tar.gz"
      sha256 "ae14f420086026ee9eb491eeb97ec9f3568413cd4d99171556ff1fb60efbfdea"
    end
  end

  on_linux do
    on_arm do
      depends_on arch: :arm64
      url "https://github.com/Maitham16/UR/releases/download/v1.87.5/ur-1.87.5-linux-arm64.tar.gz"
      sha256 "29ca067446febe8b1032331f5a65fda580b30129ddc3475021b421a5a1e630dc"
    end
    on_intel do
      depends_on arch: :x86_64
      url "https://github.com/Maitham16/UR/releases/download/v1.87.5/ur-1.87.5-linux-x64.tar.gz"
      sha256 "c59270209f1423181c832d98ffd5813c48dca5eca89607ffa1094bf10fe5b2da"
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
