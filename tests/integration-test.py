machine.start()
machine.wait_for_unit("nginx.service")

with subtest("Check root setup before deployment"):
  machine.succeed("ls -l /var/lib/www/personal-homepage")

with subtest("Base files present"):
  machine.succeed("http --check-status http://long.test.localhost/index.html")
  machine.succeed("http --check-status http://long.test.localhost/sitemap.xml")
  machine.succeed("http --check-status http://long.test.localhost/robots.txt")
  machine.succeed("http --check-status http://long.test.localhost/rss.xml")

with subtest("Aliases"):
  machine.succeed("http --check-status --follow http://test.localhost")
  machine.succeed("http --check-status --follow http://test.localhost/index.html")

with subtest("Legacy URLs still there (by redirections)"):
  machine.succeed("http --check-status --follow http://long.test.localhost/about.html")
  machine.succeed("http --check-status --follow http://long.test.localhost/resume.html")
  machine.succeed("http --check-status --follow http://long.test.localhost/blog")
  machine.succeed("http --check-status --follow http://long.test.localhost/tutorials")

with subtest("Custom redirections"):
  machine.succeed("http --check-status --follow http://long.test.localhost/example")
  machine.succeed("http --check-status --follow http://long.test.localhost/example/")

with subtest("Screenshots"):
  machine.succeed("systemctl cat homepage-screenshots.service")
  machine.succeed("systemctl start homepage-screenshots.service")
  machine.succeed("check-screenshots http://long.test.localhost")
