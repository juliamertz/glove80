{
  rustPlatform,
  fetchgit,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "dtsfmt";
  version = "v0.3.1";
  meta.mainProgram = pname;
  src = fetchgit {
    url = "https://github.com/juliamertz/${pname}.git";
    rev = "ce24df4f243130876558d6ddfb958880b6187b13";
    hash = "sha256-YVlvwZkr9m5SUY6AsG4dobvgKSeQbtAwOm/I7/kdXXc=";
  };
  cargoHash = "sha256-5fMoMaDHAAhfaTEdFwMqzD6N2zheh+AIjgCmaZZex84=";
}
