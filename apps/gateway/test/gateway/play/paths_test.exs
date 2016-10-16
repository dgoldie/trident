defmodule Gateway.Play.PathsTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized

  doctest Gateway.Play.Data
  doctest Gateway.Play.Paths

  alias Gateway.Play.Paths

  test_with_params "Gateway.Play.Paths#path?",
    fn path, expected_path ->
      assert Paths.path?(path) == expected_path
    end do
      [
        {"/request/path/neko", nil},
        {"/request/path", "/request/path"},
        {"%E3%81%82%20", nil}
      ]
  end

  test_with_params "Gateway.Play.Paths#path_pattern?",
    fn path, expected_pattern ->
      assert Paths.path_pattern?(path) == expected_pattern
    end do
      [
        {"/request_ok_case_neko", "\\A/request.*neko\\z"},
        {"/request_nekofail", nil},
        {"/request/neko", "\\A/request.*neko\\z"},
        {"/request", nil}
      ]
  end
end
