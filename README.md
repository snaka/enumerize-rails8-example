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
- **Hash-based definitions**: Using `{ admin: 'Administrator', manager: 'Manager' }` for display names
- **Predicates**: `user.admin?`, `user.manager?`, etc.
- **Scopes**: `User.with_status(:active)`
- **Default values**: role defaults to `:employee`, status defaults to `:active`
- **Text representation**: `user.role.text` returns human-readable values
- **Bulk operations**: Testing `insert_all` and `upsert_all` compatibility

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

  # Symbol array definition (should work consistently with bulk operations)
  enumerize :role, in: [:admin, :manager, :employee, :intern], 
            default: :employee, predicates: true

  # Hash definition with numeric values (potential issues with bulk operations in some versions)
  enumerize :status, in: {
    active: 0,
    inactive: 1,
    suspended: 3
  }, default: :active, scope: true

  # Multiple values with Symbol array (should work consistently)
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

## Testing the Issue with RSpec

This application includes RSpec tests that demonstrate the bulk operations issue. The tests are written to show that operations which should normally succeed actually fail in Rails 8 with this specific configuration.

```bash
# Run the tests to see the failures
bundle exec rspec spec/models/user_enumerize_bulk_operations_spec.rb

# Run with detailed output
bundle exec rspec spec/models/user_enumerize_bulk_operations_spec.rb --format documentation
```

### Expected Test Results

When running the tests, you should see:
- ✅ 7 passing tests (regular operations and configuration checks)
- ❌ 4 failing tests (bulk operations with Hash-based enum on integer columns)

The failing tests demonstrate that:
1. `insert_all` with string enum values incorrectly saves 'active' instead of 'inactive' or 'suspended'
2. `upsert_all` has the same issue
3. Multiple different status values all become 'active'
4. Updates via `upsert_all` fail to change the status

These failures confirm the issue exists in your environment.

### Key Findings

1. **🚨 CRITICAL ISSUE IDENTIFIED**: Hash-based enumerize with integer columns fails with bulk operations
2. **Symbol arrays** (role, hobbies) behave consistently with bulk operations
3. **Regular create operations** work correctly with all enum types
4. **String values in bulk operations** get incorrectly converted when using integer columns
5. **Invalid enum values** are handled gracefully (fall back to defaults)
6. **Callbacks are skipped** during bulk operations (as expected)
7. **Scopes and queries work normally** after bulk insertion

### 🐛 The Core Problem

When using **Hash-based enumerize with integer database columns**, bulk operations (`insert_all`, `upsert_all`) fail because:

- `"inactive".to_i` → `0` (maps to "active")
- `"suspended".to_i` → `0` (maps to "active")  
- Rails bypasses enumerize's conversion logic during bulk operations
- All string enum values become the first enum value (default)

### Testing Different Enum Types

This application demonstrates both approaches:
- **Symbol arrays**: `[:admin, :manager, :employee]` - consistent behavior
- **Hash definitions with numeric values**: `{ active: 0, inactive: 1, suspended: 3 }` - potential issue source in some versions

### 🔍 Reproduction Case

This application reproduces the exact issue:

**Database Schema:**
```ruby
# status column is INTEGER with numeric Hash enumerize
create_table :users do |t|
  t.integer :status, default: 0  # INTEGER column!
end

enumerize :status, in: { active: 0, inactive: 1, suspended: 3 }
```

**The Problem:**
```ruby
# ✅ Works correctly
User.create!(status: "inactive")  # → inactive

# ❌ Fails - becomes "active" instead of "inactive"  
User.insert_all([{status: "inactive"}])  # → active (wrong!)

# ✅ Works if you use numeric values
User.insert_all([{status: 1}])  # → inactive (correct)
```

**Root Cause:** Rails' bulk operations convert `"inactive"` to `0` via `String#to_i`, bypassing enumerize's proper conversion logic.

## Project Structure

```
app/
├── controllers/
│   └── users_controller.rb           # CRUD operations
├── models/
│   └── user.rb                      # User model with mixed enumerize types
├── views/
│   └── users/                       # User views for manual testing
spec/
├── models/
│   └── user_enumerize_bulk_operations_spec.rb # Tests that fail due to the issue
├── spec_helper.rb                            # RSpec configuration
└── rails_helper.rb                          # Rails-specific RSpec config
db/
├── migrate/                         # Database migrations including integer conversion
└── seeds.rb                        # Sample data
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