machine.start()
machine.wait_for_unit("nginx.service")

with subtest("Base files present"):
  machine.succeed("http --check-status http://localhost/index.html")
  machine.succeed("http --check-status http://localhost/sitemap.xml")
  machine.succeed("http --check-status http://localhost/robots.txt")
  machine.succeed("http --check-status http://localhost/rss.xml")

with subtest("Legacy URLs still there (by redirections)"):
  machine.succeed("http --check-status --follow http://localhost/about.html")
  machine.succeed("http --check-status --follow http://localhost/resume.html")
  machine.succeed("http --check-status --follow http://localhost/blog")
  machine.succeed("http --check-status --follow http://localhost/tutorials")

with subtest("Screenshots"):
  machine.succeed("systemctl cat homepage-screenshots.service")
  machine.succeed("systemctl start homepage-screenshots.service")
  machine.succeed("check-screenshots http://localhost")
