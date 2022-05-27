with import <nixpkgs> {};
mkShell {
    buildInputs = [
        fasm
        shellcheck
    ];
    shellHook = ''
        . .shellhook
    '';
}
