let
  nixpkgsNewerAgda = import (builtins.fetchTarball "https://github.com/turion/nixpkgs/archive/c3afdb9996922a974e578f8ee97d966f849bafc4.tar.gz") {};
in
nixpkgsNewerAgda.pkgs.mkShell {
  buildInputs = [ (nixpkgsNewerAgda.pkgs.agda.withPackages (pkgs: [ pkgs.standard-library ]))];
}
