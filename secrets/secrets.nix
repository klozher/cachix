let
    users = {
        gurren = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPPr8P8HoWx5U16EvZZ6QdlxnnZ0QYBg1UFO8wr9pwTs sice@gurren";
        lagann = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJV2gos20uFOdj3c7WEi7w80/x6+yezuQPo1o+MaF1J6 sice@lagann";
        giga   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7eR3TMICXrbCIoUtzHPOvSFu/iKvKMQThfS9+pj5VX sice@giga";
        pipa   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOPtHsNZjivWUit3CWaoM1Z/36zg1BKeJhv5pufVzmIP sice@pipa";
        t50    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0bzqib802Y+PQ0ss0irr4dFE/Plpns8pMhKnfgAK04 sice@t50";
    };
    systems = {
        gurren = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINHUryeYrsjwMZCOmugKsLiHPYHqrLEpZ9+aw9/Bwsoq root@gurren";
        lagann = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA73ixcSWw4n3dzxK++IyhF77nYfSW6IyF/PxCQkuSF9 root@lagann";
        giga   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINB6v7dsNxwTiIkXd66JckdD9yuIfwMNo1TEf2l6Tx3U root@giga";
        pipa   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINYqIW1jTMPXc+vGMv9UjlUc1+VWNRp1Gdv/4I2SxxDS root@pipa";
        t50    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHWeW0xoDkHFBoUCKdsvz50iB12Aj8hB5sLNH4SOhQIx root@t50";
    };
    all_keys = (builtins.attrValues users) ++ (builtins.attrValues systems);
in
{
    "passwd.age" = {
        publicKeys = all_keys;
        armor = true;
    };
    "aikey.age" = {
        publicKeys = all_keys;
        armor = true;
    };
}
