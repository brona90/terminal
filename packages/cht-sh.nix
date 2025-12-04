{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "cht.sh";
  version = "latest";

  src = fetchurl {
    url = "https://cht.sh/:cht.sh";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Update with actual hash
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/cht.sh
    chmod +x $out/bin/cht.sh
  '';

  meta = with lib; {
    description = "Cheat sheet tool for the command line";
    homepage = "https://cht.sh";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
}