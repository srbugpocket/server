{ pkgs, ... }: {
  channel = "stable-24.05";

  packages = with pkgs; [
    unzip
    git
    qemu_kvm
    cdrkit
    cloud-utils
    qemu
    qemu-utils
    e2fsprogs
    sudo

  ];

  env = {
    EDITOR = "nano";
  };

  idx = {
    workspace = {
      onCreate = { };
      onStart = { };
    };

    previews = {
      enable = false;
    };
  };
}
