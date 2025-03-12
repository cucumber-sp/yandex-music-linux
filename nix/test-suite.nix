/*
  This test suite uses nixos common x11 and user-account test configurations.
  Those configurations use auto-login to ice-wm desktop manager.
  This test configuration enables yandex-music application, launches it and
  check for window existence. Additionally it takes screenshot after successful
  launch to allow to validate state manually. The result may miss the content
  inside window because of lack of GPU support.

  TODO(Shvedov): We should to perform automatic checks of screen state.
*/
{
  testers,
  path,

  # The yandex-music module
  nixosModule,
  # The extra configuration
  configuration ? { },
  # The extra code of test script
  extraTestScript ? "",
  # The name of test
  name ? "yandex-music-test",
}:
testers.runNixOSTest {
  inherit name;
  nodes.machine =
    let
      tests = "${path}/nixos/tests/common/";
      user = "alice";
    in
    {
      imports = [
        nixosModule
        "${tests}/x11.nix"
        "${tests}/user-account.nix"
        configuration
      ];
      test-support.displayManager.auto.user = user;
      programs.yandex-music.enable = true;
    };

  testScript =
    ''
      # We have to execute command with su beckause all commands performs under
      # the root user.
      def mk_command(command, tail = "", fork = False):
        if fork:
          tail = f"{tail} >&2 &"
        return f"su -c '{command}' - alice {tail}"

      machine.wait_for_x()
      machine.execute(mk_command("yandex-music", fork = True))

      check_command = mk_command('xwininfo -root -tree', tail = "| grep 'Яндекс Музыка'")

      machine.wait_until_succeeds(check_command, 120)
      machine.sleep(40)
      machine.succeed(check_command)
      machine.screenshot("screen")
    ''
    + extraTestScript;
}
