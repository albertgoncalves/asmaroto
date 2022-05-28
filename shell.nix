with import <nixpkgs> {};
mkShell.override { stdenv = llvmPackages_14.stdenv; } {
    buildInputs = [
        fasm
        mold
        shellcheck
    ];
    shellHook = ''
        . .shellhook
    '';
}
