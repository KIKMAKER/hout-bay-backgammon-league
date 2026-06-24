Loan.destroy_all
Book.destroy_all

4.times do |i|
  Book.create!(
    title: "Backgammon: From Basics to Badass – Copy #{i + 1}",
    author: "Marc Olsen"
  )
end

puts "✅ Created #{Book.count} books."
