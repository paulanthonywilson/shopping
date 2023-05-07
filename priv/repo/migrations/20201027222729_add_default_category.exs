defmodule Shopping.Repo.Migrations.AddDefaultCategory do
  use Ecto.Migration

  def up do
    repo().query!(
      "INSERT INTO categories (id, emoji, category_name, ordering, inserted_at, updated_at) VALUES ($1, $2, $3, $4, now(), now())",
      [0, "🤷🏻‍♀️", "unknown", 0]
    )
  end

  def down do
    repo().query!("DELETE FROM categories WHERE id = 0")
  end
end
