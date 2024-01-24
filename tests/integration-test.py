machine.start()
machine.wait_for_unit("nginx.service")

with subtest("Base files present"):
  machine.succeed("http http://localhost/index.html")
  machine.succeed("http http://localhost/sitemap.xml")
  machine.succeed("http http://localhost/robots.txt")

with subtest("Legacy URLs still there (by redirections)"):
  machine.succeed("http http://localhost/about.html")
  machine.succeed("http http://localhost/resume.html")
  machine.succeed("http http://localhost/blog")
  machine.succeed("http http://localhost/tutorials")

with subtest("Screenshots"):
  machine.succeed("su - test_user -c \"mkdir -p screenshots\"")
  machine.succeed("su - test_user -c \"take-screenshots http://localhost/ screenshots\"")
