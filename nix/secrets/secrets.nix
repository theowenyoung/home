let
  system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINAPcRy9wGjP47bHpv2RcNO3yw3udCcTlgWs22KLcpUW main@example.com";
  nixos1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOTAROXsvgKDzztILO8mPPRv6HZamQa7M05kzNM8gtQZ root@nixos";
  systems = [ system1 nixos1 ];
in
{
  "meilisearch.age".publicKeys = [system1 nixos1];
}
