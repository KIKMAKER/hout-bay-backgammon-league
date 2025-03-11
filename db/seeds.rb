# Destroy existing data (only use in development)
Match.destroy_all
Cycle.destroy_all
Group.destroy_all
User.destroy_all

# Create Groups
groups = ["Group A", "Group B", "Group C"].map { |name| Group.create!(title: name) }
puts "✅ Created #{groups.size} groups"

# Create Users
users = []
groups.each do |group|
  6.times do |i|
    users << User.create!(
      username: "#{group.title}_Player#{i+1}",
      email: "#{group.title.gsub(" ", "_").downcase}_player#{i+1}@example.com",
      password: "password",
      group_id: group.id
    )
  end
end
puts "✅ Created #{users.size} users"

# Create Cycles (One per group)
cycles = groups.map { |group| Cycle.create!(start_date: Date.today, end_date: Date.today + 10.weeks, group: group) }
puts "✅ Created #{cycles.size} cycles"

# Generate Round-Robin Matches for Each Cycle
cycles.each do |cycle|
  players = cycle.group.users.to_a

  players.combination(2).each do |player1, player2|
    match = Match.create!(
      player1: player1,
      player2: player2,
      cycle: cycle,
      match_date: Date.today + rand(1..30).days # Random future match dates
    )

    # Randomly mark some matches as completed
    if rand < 0.5
      match.update!(
        player1_score: rand(5..11),
        player2_score: rand(5..11),
      )
    end
    
    if match.player1_score
      match.update!(
        winner: match.player1_score > match.player2_score ? match.player1 : match.player2
      )
    end
  end
end

puts "✅ Generated matches for all cycles"

puts "🎉 Seeding complete! You can now test match reporting, history, standings, and leaderboards."
