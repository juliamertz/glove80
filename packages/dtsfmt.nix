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
  # src = inputs.dtsfmt;
  src = fetchgit {
    url = "https://github.com/juliamertz/${pname}.git";
    rev = "a80ab3e56d52fda659bcd3860750ca7ec553944c";
    hash = "sha256-a641ypgBy2mQU9wZyCl7nQEwplarrnFvg7vjXKbkd78=";
  };
  # src = runCommand "src" { } ''
  #   mkdir -p $out/tree-sitter-devicetree
  #   cp -r ${inputs.dtsfmt}/* $out/
  #   cp -r ${inputs.treesitter-devicetree}/* $out/tree-sitter-devicetree
  # '';
  meta.mainProgram = "dtsfmt";
  cargoHash = "sha256-5fMoMaDHAAhfaTEdFwMqzD6N2zheh+AIjgCmaZZex84=";
}
