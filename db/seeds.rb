# db/seeds.rb

puts "Destroying all data..."
Match.destroy_all
Cycle.destroy_all
Group.destroy_all
User.destroy_all
puts "✅ All data destroyed."

# 1) CREATE GROUPS
group_a = Group.create!(title: "Group A")
group_b = Group.create!(title: "Group B")
puts "✅ Created 2 groups: #{Group.pluck(:title).join(', ')}"

# 2) CREATE USERS

group_a_players = [
  { username: "Louise Muller", email: "louise_muller@example.com" },
  { username: "Paul Rutzen", email: "paul_rutzen@example.com" },
  { username: "Amir Kaap", email: "amir_kaap@example.com" },
  { username: "Liza Kaap", email: "liza_kaap@example.com" },
  { username: "Nigel Mullin", email: "nigel_mullin@example.com" },
  { username: "Graeme Reay", email: "graham_reay@example.com" },
  { username: "Trudi van Wyk", email: "trudi_van_wyk@example.com" },
  { username: "Alexa Sanchez", email: "alexa_sanchez@example.com" },
  { username: "Keith Gow", email: "keith_gow@example.com" },
  # Rob is admin
  { username: "Rob Kennedy", email: "rob_kennedy@example.com", admin: true }
]

group_b_players = [
  { username: "Giuseppe Carosini", email: "giuseppe_carosini@example.com" },
  { username: "Mikey Dredd", email: "mikey_dredd@example.com" },
  { username: "Clynton Tarboton", email: "clynton_tarboton@example.com" },
  { username: "Costa Vass", email: "costa_vass@example.com" },
  { username: "Dane Wise", email: "dane_wise@example.com" },
  { username: "Richenda Slingerland", email: "richenda_slingerland@example.com" },
  { username: "Mark Sherwood", email: "mark_sherwood@example.com" },
  { username: "Natasha Lockwood", email: "natasha_lockwood@example.com" },
  { username: "Lulu Cohen", email: "lulu_cohen@example.com" },
  { username: "Julian Wannel", email: "julian_wannel@example.com" }
]
User.create(username: "Kiki Kennedy", email: "kiki_kennedy@example.com", admin: true, password: 'houtbay')
puts "Created Kiki as admin"
def create_users_for_group(players, group)
  players.each do |player_data|
    User.create!(
      username: player_data[:username],
      email: player_data[:email],
      password: "houtbay", # All share the same password
      admin: player_data[:admin] || false,
      group: group
    )
  end
end

create_users_for_group(group_a_players, group_a)
create_users_for_group(group_b_players, group_b)

puts "✅ Created #{User.count} users."

# 3) PROMPT TO CREATE CYCLES & MATCHES
puts "\nDo you want to create a cycle and generate matches for each group? (y/n)"
answer = gets.chomp.downcase

if answer == "y"
  [group_a, group_b].each do |group|
    # Example cycle attributes (you can tweak these)
    cycle = Cycle.create!(
      group: group,
      start_date: Date.today,
      end_date: Date.today + 10.weeks,
      weeks: 9, # your number of 'active' playing weeks
      catch_up_weeks: 1 # optional extra column if you want
    )
    puts "✅ Created a cycle for #{group.title} (ID: #{cycle.id})"

    # Generate round-robin matches (or random scheduling):
    players = group.users.to_a
    players.combination(2).each do |player1, player2|
      match = Match.create!(
        player1: player1,
        player2: player2,
        cycle: cycle,
        match_date: cycle.start_date + rand(0..(cycle.weeks * 7)).days
      )

      # Randomly finalize ~half of them
      if rand < 0.5
        match.update!(
          player1_score: rand(5..11),
          player2_score: rand(5..11)
        )
        # Set winner
        if match.player1_score && match.player2_score
          match.update!(
            winner: match.player1_score > match.player2_score ? match.player1 : match.player2
          )
        end
      end
    end

    puts "✅ Generated matches for #{group.title}"
  end

  puts "🎉 Cycle and match generation complete!"
else
  puts "Skipping cycle & match creation."
end

puts "Seeding finished!"
