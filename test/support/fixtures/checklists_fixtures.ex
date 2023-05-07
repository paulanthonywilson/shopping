defmodule Shopping.ChecklistsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shopping.Checklists` context.
  """

  @doc """
  Generate a checklist.
  """
  def checklist_fixture(attrs \\ %{}) do
    {:ok, checklist} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Shopping.Checklists.create_checklist()

    checklist
  end
end
