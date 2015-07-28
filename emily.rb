class Emily < Formula
  homepage "http://emilylang.org"
  url "https://bitbucket.org/runhello/emily/get/emily-0.2.tar.bz2"
  sha256 "9707eb76f0c6e51d36f6e30b3df1ec5b71849cab90613ba871650dddd6768fd5"
  head "https://bitbucket.org/runhello/emily", :using => :hg,
    :branch => "stable"

  depends_on "objective-caml" => :build
  depends_on "opam" => :build

  def install
    # delete environment variables set by opam,
    # which may interfere with the build
    ENV.delete "CAML_LD_LIBRARY_PATH"
    ENV.delete "OCAML_TOPLEVEL_PATH"

    ENV["OPAMROOT"] = buildpath/"dependencies"
    ENV.prepend "PATH", buildpath/"dependencies/system/bin", File::PATH_SEPARATOR

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
