class Jxcore < Formula
  desc "Evented IO for ChakraCore, SpiderMonkey & V8 JavaScript"
  homepage "https://github.com/jxcore/jxcore"
  version "0.3.1.4"
  url "http://jxcore.azureedge.net/jxcore/0314/release/jx_osx64v8.zip"
  sha256 "ebee1b62f0852939bb3e11f710b8c567b7443b8ea01e473254c7c5a8e8ec1272"

  resource "sm" do
    url "http://jxcore.azureedge.net/jxcore/0314/release/jx_osx64sm.zip"
    sha256 "b4f7f33137ab51f3d5e969b08acc8182c97ed8a5c3ad16e63b2f842609543e04"
  end

  bottle :unneeded

  # option "with-sm", "Installs SpiderMonkey version"

  def install
      bin.install buildpath/"jx"
  end

end
