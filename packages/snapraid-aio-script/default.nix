{ lib, stdenv, fetchFromGitHub, makeWrapper, pkgs, snapraid-aio-config, ... }:

let
  inherit (lib) makeBinPath;
  inherit (lib.strings) escape;

  python-packages = p: with p; [
    markdown
  ];

  runtimeDeps = with pkgs; [
    snapraid
    procps # for pgrep
    smartmontools
    (pkgs.python3.withPackages python-packages)
  ];

  escapePath = path: escape [ "/" ] (toString path);
  setOption = option: value: "sed -i'' 's/^${option}=.*/${option}=\"${value}\"/g' script-config.sh";

in
stdenv.mkDerivation rec {
  pname = "snapraid-aio-script";
  version = "3.2";

  src = fetchFromGitHub {
    owner = "auanasgheps";
    repo = "snapraid-aio-script";
    rev = "v${version}";
    sha256 = "sha256-nnAcMuQOnpjoQGMSfJKuEEisnQ/DfIJPwk3ZbDxJ7Nk=";
  };

  patches = [
    ./patches/0001-disable-markdown-installation.patch
    ./patches/0002-don-t-set-PATH.patch
  ];

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ ];

  buildPhase = ''
    ${setOption "EMAIL_ADDRESS" snapraid-aio-config.emailAddress}
    ${setOption "FROM_EMAIL_ADDRESS" snapraid-aio-config.fromEmailAddress}
    ${setOption "SNAPRAID_BIN" (escapePath (pkgs.snapraid + "/bin/snapraid"))}
    ${setOption "MAIL_BIN" (escapePath (pkgs.mailutils + "/bin/mail"))}
  '';

  installPhase = ''
    install -Dm755 snapraid-aio-script.sh $out/bin/snapraid-aio-script
    install -Dm755 script-config.sh $out/bin/script-config.sh

    wrapProgram $out/bin/snapraid-aio-script --prefix PATH : '${makeBinPath runtimeDeps}'
  '';

  meta = {
    description = "The definitive all-in-one SnapRAID script";
    longDescription = "Diff, sync, scrub are things of the past. Manage SnapRAID and much, much more!";
    homepage = "https://github.com/auanasgheps/snapraid-aio-script";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
  };
}
