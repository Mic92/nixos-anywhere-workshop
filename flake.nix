{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;

  inputs.disko.url = github:nix-community/disko/make-disk-image;
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nixos-anywhere.url = "github:numtide/nixos-anywhere";
  inputs.nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, disko, nixos-anywhere, ... }@attrs: {
    packages."x86_64-linux".makeDiskImageTest = disko.lib.lib.makeDiskImage {
      nixosConfig = self.nixosConfigurations.mysystem;
    };
    packages."x86_64-linux".makeDiskScriptTest = disko.lib.lib.makeDiskImageScript {
      nixosConfig = self.nixosConfigurations.mysystem;
    };
    nixosConfigurations.mysystem = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        (nixpkgs.outPath + "/nixos/modules/installer/scan/not-detected.nix")
        disko.nixosModules.disko
        ./disk-configs/simple-efi.nix # choose your favorite disk layout here
        {
          boot.loader.grub = {
            efiSupport = true;
            efiInstallAsRemovable = true;
          };
        }
      ];
    };
  };
}
