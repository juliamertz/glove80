{ pkgs }:
let
  inherit (pkgs) lib;
  nativeBuildInputs =
    with pkgs;
    [
      pkg-config
      rustPlatform.bindgenHook
    ]
    ++ lib.optionals stdenv.isDarwin [ makeBinaryWrapper ];
  buildInputs =
    with pkgs;
    [ openssl ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [ IOKit ]);

  name = "firmware-loader";
in
pkgs.rustPlatform.buildRustPackage {
  inherit name buildInputs nativeBuildInputs;

  src = pkgs.fetchFromGitHub {
    owner = "jereanon";
    repo = "glove80-firmware-updater";
    rev = "5bad4baba6b789a7a26362f54d1c27ef3eb8e5e7";
    sha256 = "sha256-KXj0fgDI3DYsePWopbfZhBN8E4eEyVQK/4/29YXG8Bo=";
  };

  cargoHash = "";
  # src = ./.;
  # cargoLock = {
  #   lockFile = ./Cargo.lock;
  #   allowBuiltinFetchGit = true;
  # };

  version = "0.1.0";
  meta.mainProgram = name;
}
