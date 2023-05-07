defmodule ShoppingWeb.ItemGotAgeTest do
  use ExUnit.Case, async: true

  alias ShoppingWeb.ItemGotAge

  @test_now ~U[2020-12-30 12:00:00Z]

  test "no last got" do
    assert ItemGotAge.got_age(%{last_got: nil}) == ""
  end

  test "less than an hour" do
    assert ItemGotAge.got_age(@test_now, item_got_ago_seconds(1)) ==
             "last hour"

    assert ItemGotAge.got_age(@test_now, item_got_ago_seconds(60 * 60 - 1)) ==
             "last hour"
  end

  test "1 hour ago" do
    assert ItemGotAge.got_age(@test_now, item_got_ago_seconds(60 * 60)) ==
             "1 hour"

    assert ItemGotAge.got_age(@test_now, item_got_ago_seconds(2 * 60 * 60 - 1)) ==
             "1 hour"
  end

  test "hours up to a day" do
    assert ItemGotAge.got_age(@test_now, item_got_ago_seconds(2 * 60 * 60)) ==
             "2 hours"

    assert ItemGotAge.got_age(@test_now, item_got_ago_seconds(3 * 60 * 60 - 1)) ==
             "2 hours"

    assert ItemGotAge.got_age(@test_now, item_got_ago_seconds(24 * 60 * 60 - 1)) ==
             "23 hours"
  end

  test "day ago" do
    assert ItemGotAge.got_age(@test_now, item_got_ago_seconds(24 * 60 * 60)) ==
             "1 day"

    assert ItemGotAge.got_age(@test_now, item_got_ago_seconds(2 * 24 * 60 * 60 - 1)) ==
             "1 day"
  end

  test "days ago" do
    assert ItemGotAge.got_age(@test_now, item_got_ago_seconds(2 * 24 * 60 * 60)) ==
             "2 days"

    assert ItemGotAge.got_age(@test_now, item_got_ago_seconds(6 * 24 * 60 * 60)) ==
             "6 days"
  end

  def item_got_ago_seconds(seconds) do
    %{last_got: DateTime.add(@test_now, -seconds)}
  end
end
