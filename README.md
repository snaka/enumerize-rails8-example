# Rails 8 with Enumerize Demo Application

A simple demonstration application showcasing the [Enumerize](https://github.com/brainspec/enumerize) gem features in Rails 8. This application provides a practical example of how to implement enumerable attributes with internationalization support.

## Overview

This demo application implements a User management system that demonstrates various Enumerize features:
- Single-value enumerations (role, status)
- Multi-value enumerations (hobbies)
- Predicate methods
- Scopes
- Form integration
- Internationalization support

## Features Demonstrated

### 1. Basic Enumeration
- **Role**: admin, manager, employee, intern
- **Status**: active, inactive, suspended

### 2. Multiple Selection
- **Hobbies**: reading, sports, cooking, gaming, music, travel

### 3. Enumerize Features
- **Predicates**: `user.admin?`, `user.manager?`, etc.
- **Scopes**: `User.with_status(:active)`
- **Default values**: role defaults to `:employee`, status defaults to `:active`
- **Text representation**: `user.role.text` returns human-readable values

## Requirements

- Ruby 3.3.5 or higher
- Rails 8.0.1 or higher
- SQLite3

## Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/enumerize-rails8.git
cd enumerize-rails8
```

2. Install dependencies
```bash
bundle install
```

3. Setup the database
```bash
rails db:create
rails db:migrate
rails db:seed
```

4. Start the Rails server
```bash
rails server
```

5. Visit `http://localhost:3000` in your browser

## Usage

The application provides a full CRUD interface for managing users:

1. **List Users**: View all users with their roles, statuses, and hobbies
2. **Create User**: Add new users with enumerated attributes
3. **View User**: See detailed information including predicate method results
4. **Edit User**: Update user information with dropdown selects
5. **Delete User**: Remove users from the system

## Code Examples

### Model Definition

```ruby
class User < ApplicationRecord
  extend Enumerize

  # Single value with predicates
  enumerize :role, in: [:admin, :manager, :employee, :intern], 
            default: :employee, predicates: true

  # Single value with scopes
  enumerize :status, in: [:active, :inactive, :suspended], 
            default: :active, scope: true

  # Multiple values
  serialize :hobbies, coder: JSON, type: Array
  enumerize :hobbies, in: [:reading, :sports, :cooking, :gaming, :music, :travel], 
            multiple: true
end
```

### Using in Views

```erb
<!-- Display text representation -->
<%= user.role.text %>

<!-- Form select -->
<%= form.select :role, options_for_select(User.role.options) %>

<!-- Multiple select -->
<%= form.select :hobbies, options_for_select(User.hobbies.options), {}, multiple: true %>
```

### Using Predicates and Scopes

```ruby
# Predicates
user.admin?      # => true/false
user.employee?   # => true/false

# Scopes
User.with_status(:active)     # => Returns all active users
User.with_status(:suspended)  # => Returns all suspended users
```

## Sample Data

The application comes with pre-seeded data featuring 6 users with different combinations of roles, statuses, and hobbies. Run `rails db:seed` to populate the database.

## Project Structure

```
app/
├── controllers/
│   └── users_controller.rb    # CRUD operations
├── models/
│   └── user.rb               # User model with enumerize
├── views/
│   └── users/                # User views
│       ├── _form.html.erb    # Shared form partial
│       ├── index.html.erb    # User listing
│       ├── show.html.erb     # User details
│       ├── new.html.erb      # New user form
│       └── edit.html.erb     # Edit user form
└── db/
    └── seeds.rb              # Sample data

```

## Key Learning Points

1. **Enumerize vs Rails Enum**: Enumerize provides better internationalization support and more features out of the box
2. **Form Integration**: Seamlessly works with Rails form helpers
3. **Database Storage**: Values are stored as strings, making them database-agnostic
4. **Flexibility**: Supports both single and multiple value selections

## Contributing

This is a demonstration application for learning purposes. Feel free to fork and experiment with additional Enumerize features!

## License

This project is open source and available under the [MIT License](LICENSE).

## Resources

- [Enumerize Documentation](https://github.com/brainspec/enumerize)
- [Rails 8 Documentation](https://guides.rubyonrails.org/)
- [Rails Enum Documentation](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html)

## Author

Created as a demonstration of Enumerize features in Rails 8.