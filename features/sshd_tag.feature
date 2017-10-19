Feature: @sshd cucumber tag

  @sshd
  Scenario: allows connection to a running sshd
    When I run "echo \$SSH_CONNECTION" remotely
    Then the output must contain "2222"

  @sshd
  Scenario: logs the user in aruba current directory
    When I run "pwd" remotely
    Then the output must be aruba current directory

  @sshd
  Scenario: allows sftp usage
    When I run "bye" sftp command remotely
    Then the output must contain "Connected"

  @sshd
  Scenario: sources .ssh/rc on new session
    Given a file named ".ssh/rc" with:
      """
      echo some message
      """
    When I run "true" remotely
    Then the output must contain "some message"

  @sshd
  Scenario: silences sshd output
    When I run "true" remotely
    Then the output must be empty
