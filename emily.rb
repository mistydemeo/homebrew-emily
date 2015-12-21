class Emily < Formula
  desc "The Emily language, an experimental oo ∩ fp programming language " \
  "created by Andi McClure."
  homepage "http://emilylang.org"
  url "https://bitbucket.org/runhello/emily/get/emily-0.2.tar.bz2"
  sha256 "9707eb76f0c6e51d36f6e30b3df1ec5b71849cab90613ba871650dddd6768fd5"
  head "https://bitbucket.org/runhello/emily",
    :using  => :hg,
    :branch => "stable"

  devel do
    url "https://bitbucket.org/runhello/emily/get/unstable.tar.bz2"
    sha256 "df2ca6a7bbb7e26eb0a91a7d4b19c7ccf2f53b8e740814f4ef90b135290e9cfd"
    version "0.3b"
  end

  depends_on "ocaml" => :build
  depends_on "opam" => :build

  def install
    # delete environment variables set by opam,
    # which may interfere with the build
    ENV.delete "CAML_LD_LIBRARY_PATH"
    ENV.delete "OCAML_TOPLEVEL_PATH"

    ENV["OPAMROOT"] = buildpath/"dependencies"
    ENV.prepend "PATH", buildpath/"dependencies/system/bin", File::PATH_SEPARATOR

    install_ocaml_deps

    # Otherwise ocamlbuild will mistake the fetched dependencies for "dirty" files
    inreplace "Makefile", "ocamlbuild -no-links", "ocamlbuild -no-links -no-hygiene"
    system "make", "install", "PREFIX=#{prefix}"
  end

  def ocaml_deps
    devel_deps = ["ctypes.0.4.1", "ctypes-foreign.0.4.0", "ppx_getenv.1.1",
                  "ppx_const.1.1", "uutf.0.9.4"]
    base_deps  = ["ocamlfind.1.5.5", "sedlex.1.99.2", "containers.0.9",
                  "fileutils.0.4.4"]

    devel? ? base_deps.push(devel_deps) : base_deps
  end

  def install_ocaml_deps
    system "opam init --no-setup"
    system ["opam install --yes"].push(ocaml_deps).join(" ")
  end

  test do
    (testpath/"hello.em").write <<-EOS.undent
    println "Hello world!"
    EOS

    system "#{bin}/emily", "hello.em"
  end
end
