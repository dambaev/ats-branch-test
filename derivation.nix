{ stdenv, pkgs, fetchzip, fetchpatch, fetchgit, fetchurl }:
stdenv.mkDerivation {
  name = "test1";

  src = ./.;
  buildInputs = with pkgs;
  [ ats2
    which
  ];
}
