defmodule Shopping.Repo.Migrations.AddLastCheckedToItems do
  use Ecto.Migration

  def up do
    alter table(:items) do
      add :last_got, :utc_datetime
    end

    flush()
    repo().query!("UPDATE items SET last_got = updated_at WHERE \"got?\" = 't'")
  end

  def down do
    alter table(:items) do
      remove :last_checked, :utc_datetime
    end
  end
end
