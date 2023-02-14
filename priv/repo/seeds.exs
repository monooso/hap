# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Hap.Repo.insert!(%Hap.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Hap.Factory

amazon = insert(:organization, name: "Amazon")

projects =
  [
    insert(:project, name: "Books", organization: amazon),
    insert(:project, name: "Films", organization: amazon),
    insert(:project, name: "Games", organization: amazon),
    insert(:project, name: "Music", organization: amazon)
  ]
  |> Enum.each(fn project ->
    insert_list(100, :event,
      name: "Order placed",
      message: "Mad dollar bills, yo",
      project: project,
      tags: ["kpi", "sales"]
    )

    insert_list(100, :event,
      name: "Order shipped",
      message: "Ship it squirrel",
      project: project,
      tags: ["kpi"]
    )

    insert_list(50, :event,
      name: "Review posted",
      message: "A person on the internet has an opinion",
      project: project,
      tags: ["customer_engagement"]
    )

    insert_list(25, :event,
      name: "Refund requested",
      message: "Customers are the worst",
      project: project,
      tags: ["kpi", "support"]
    )
  end)
