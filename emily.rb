class Emily < Formula
  homepage "http://emilylang.org"
  url "https://bitbucket.org/runhello/emily/get/emily-0.1.tar.bz2"
  sha1 "0469f40981732357d283723beb94f4eb1fc8a5f4"
  head "https://bitbucket.org/runhello/emily", :using => :hg,
    :branch => "stable"

  depends_on "objective-caml" => :build
  depends_on "opam" => :build

  def install
    ENV["OPAMROOT"] = buildpath/"dependencies"
    ENV.append "PATH", buildpath/"dependencies/system/bin", File::PATH_SEPARATOR

    system "opam", "init", "--no-setup"
    system "opam", "install", "--yes", "ocamlfind.1.5.5", "sedlex.1.99.2", "containers.0.9", "fileutils.0.4.4"

    # Otherwise ocamlbuild will mistake the fetched dependencies for "dirty" files
    inreplace "Makefile", "ocamlbuild -no-links", "ocamlbuild -no-links -no-hygiene"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"hello.em").write <<-EOS.undent
    println "Hello world!"
    EOS

    system "#{bin}/emily", "hello.em"
  end
end
