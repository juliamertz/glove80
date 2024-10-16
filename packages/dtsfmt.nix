{
  rustPlatform,
  fetchgit,
  # runCommand,
  # inputs,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "dtsfmt";
  version = "v0.3.1";
  meta.mainProgram = pname;
  src = fetchgit {
    url = "https://github.com/juliamertz/${pname}.git";
    rev = "b47a3720002ca06d657c7147f7dc56ca7abd68eb";
    hash = "sha256-iepKJVZmCPo6TKoy1+kI41N7tDy+Ozf2SjW9bkcVmLo=";
  };
  cargoHash = "sha256-5fMoMaDHAAhfaTEdFwMqzD6N2zheh+AIjgCmaZZex84=";
}
