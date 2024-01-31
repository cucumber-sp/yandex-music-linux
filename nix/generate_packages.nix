{ jq
, curl
, runCommand
, lib
, makeWrapper
}:
let
  paths = lib.makeBinPath [ jq curl ];
in
runCommand "generate_config"
{
  src = ../generate_packages.sh;
  name = "generate_packages";
  nativeBuildInputs = [
    makeWrapper
  ];
} ''
  mkdir -p "$out/bin"
  bin="$out/bin/$name"
  cp "$src" "$bin"
  chmod +x "$bin"
  patchShebangs "$bin"
  wrapProgram "$bin" \
    --prefix PATH : ${paths}
''
