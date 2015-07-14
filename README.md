cucumber-sshd
=============

  This ruby gem runs a "fake" sshd process for testing purpose in
cucumber scenario tagged as `@sshd`. It is especially useful when
testing programs with aruba, like a provisioning program that would
connect through ssh for example.

  The process is real, but the HOME environment variable will be
modified as aruba current directory, and the port changed so an
unprivileged can open it. Host key pair is hard coded, output is
silenced, server will only listen on localhost with sftp enabled, and
a standard ssh config file is written in `.ssh/config`.

  Optionally, cucumber process will block until sshd accepts
connection, and the same sshd process can also be configured to
persist across the whole test suite for faster run.


Warning
-------

* pollute cucumber contexts with multiple instance variables
* pollute global context with a variable
* uses `Kernel#at_exit` when `wait_ready` option is enabled


Usage
-----

### cucumber config

```ruby
Before do
  # Persists the sshd process across tests (default is to start and
  # stop around each test).
  @_sshd_fast       = true

  # Block cucumber process until sshd accepts new connections.
  @_sshd_wait_ready = true
end
require 'cucumber/sshd/cucumber'
```

### runtime config

You can control the host name and the port with environment variables.
Here are the defaults:

    SSHD_TEST_HOST=some_host.test
    SSHD_TEST_PORT=2222
