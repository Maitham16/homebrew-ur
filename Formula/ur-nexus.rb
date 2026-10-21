# Generated from the immutable native release manifest. Do not edit checksums by hand.
# Source commit: 87b55809dff709c1054dd0d31f84bbb80ef1fb9a
class UrNexus < Formula
  desc "Terminal coding agent with a bundled runtime and local-first provider support"
  homepage "https://github.com/Maitham16/UR"
  version "1.87.1"
  license :cannot_represent

  # Keep upstream native library IDs and resource-integrity hashes intact.
  preserve_rpath
  skip_clean "libexec"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      depends_on arch: :arm64
      url "https://github.com/Maitham16/UR/releases/download/v1.87.1/ur-1.87.1-darwin-arm64.tar.gz"
      sha256 "9430640d1e72d492193e9196b6a287d7a827b4880ac64470879a888432dff78c"
    end
    on_intel do
      depends_on arch: :x86_64
      url "https://github.com/Maitham16/UR/releases/download/v1.87.1/ur-1.87.1-darwin-x64.tar.gz"
      sha256 "006326a3fabb656da987f414c371420a9a7eb73f0a8420e7e9a6bc6cb97d2e35"
    end
  end

  on_linux do
    on_arm do
      depends_on arch: :arm64
      url "https://github.com/Maitham16/UR/releases/download/v1.87.1/ur-1.87.1-linux-arm64.tar.gz"
      sha256 "aa3d4d22f27fdc93e4edd9a7ca8b49fef1c605669a65bf05da76c2267afed79c"
    end
    on_intel do
      depends_on arch: :x86_64
      url "https://github.com/Maitham16/UR/releases/download/v1.87.1/ur-1.87.1-linux-x64.tar.gz"
      sha256 "9cdbe5ef8020988467d1789cfc8099fcf0240386a3b9181c72a27e42bf12a624"
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
