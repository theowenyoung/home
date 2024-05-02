let
  system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINAPcRy9wGjP47bHpv2RcNO3yw3udCcTlgWs22KLcpUW main@example.com";
  systems = [ system1 ];
in
{
  "meilisearch.age".publicKeys = [system1 ];
}
