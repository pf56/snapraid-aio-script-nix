# snapraid-aio-script-nix

A Nix Flake for [auanasgheps' snapraid-aio-script](https://github.com/auanasgheps/snapraid-aio-script/).

## Usage

1. Add a flake input
```
inputs = {
    snapraid-aio-script = {
      url = "sourcehut:~pf56/snapraid-aio-script-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
```

2. Pass the module to your system configuration

```
outputs = { self, nixpkgs, snapraid-aio-script, ... }@attrs: {
    nixosConfigurations.myConfig = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        snapraid-aio-script.nixosModules.snapraid-aio-script
        ./configuration.nix
      ];
    };
  };
```

3. Configure
 ```
 services.snapraid-aio-script = {
    enable = true;
    emailAddress = "user@example.com";
    fromEmailAddress = "user@example.com";
  };
 ```

 You will need to configure an SMTP client like msmtp as well.