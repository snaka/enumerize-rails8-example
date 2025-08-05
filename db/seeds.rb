# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Sample user data
users_data = [
  {
    name: "John Smith",
    email: "john.smith@example.com",
    role: :admin,
    status: :active,
    hobbies: [:reading, :travel]
  },
  {
    name: "Sarah Johnson",
    email: "sarah.johnson@example.com",
    role: :manager,
    status: :active,
    hobbies: [:cooking, :music]
  },
  {
    name: "Michael Brown",
    email: "michael.brown@example.com",
    role: :employee,
    status: :active,
    hobbies: [:sports, :gaming]
  },
  {
    name: "Emily Davis",
    email: "emily.davis@example.com",
    role: :employee,
    status: :inactive,
    hobbies: [:reading, :cooking, :travel]
  },
  {
    name: "David Wilson",
    email: "david.wilson@example.com",
    role: :intern,
    status: :active,
    hobbies: [:gaming]
  },
  {
    name: "Jennifer Martinez",
    email: "jennifer.martinez@example.com",
    role: :manager,
    status: :suspended,
    hobbies: [:music, :sports, :travel]
  }
]

users_data.each do |user_data|
  User.find_or_create_by!(email: user_data[:email]) do |user|
    user.name = user_data[:name]
    user.role = user_data[:role]
    user.status = user_data[:status]
    user.hobbies = user_data[:hobbies]
  end
end

puts "Created #{User.count} users."