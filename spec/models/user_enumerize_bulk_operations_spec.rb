require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'enumerize with bulk operations' do
    let(:user_data) do
      {
        name: 'Test User',
        email: 'test@example.com',
        role: 'admin',
        status: 'inactive',
        hobbies: ['reading', 'travel']
      }
    end

    after do
      User.where(email: user_data[:email]).delete_all
    end

    describe 'regular create operations' do
      it 'correctly saves string values for Hash-based enum' do
        user = User.create!(user_data)
        
        expect(user.status.to_s).to eq('inactive')
        expect(user.role.to_s).to eq('admin')
        expect(user.hobbies.map(&:to_s)).to contain_exactly('reading', 'travel')
      end

      it 'correctly saves symbol values for Hash-based enum' do
        user = User.create!(user_data.merge(status: :suspended))
        
        expect(user.status.to_s).to eq('suspended')
      end
    end

    describe 'bulk insert operations' do
      context 'with insert_all' do
        it 'correctly saves string values for Hash-based enum' do
          User.insert_all([user_data])
          user = User.find_by(email: user_data[:email])
          
          # This test SHOULD pass but FAILS in Rails 8 with integer columns
          # The status becomes 'active' instead of 'inactive'
          expect(user.status.to_s).to eq('inactive')
        end

        it 'correctly saves multiple different status values' do
          users_data = [
            user_data,
            user_data.merge(email: 'test2@example.com', status: 'suspended'),
            user_data.merge(email: 'test3@example.com', status: 'active')
          ]
          
          User.insert_all(users_data)
          
          user1 = User.find_by(email: 'test@example.com')
          user2 = User.find_by(email: 'test2@example.com')
          user3 = User.find_by(email: 'test3@example.com')
          
          # These tests SHOULD pass but FAIL for non-active statuses
          expect(user1.status.to_s).to eq('inactive')
          expect(user2.status.to_s).to eq('suspended')
          expect(user3.status.to_s).to eq('active')
        end

        it 'correctly saves Symbol array enum values' do
          User.insert_all([user_data])
          user = User.find_by(email: user_data[:email])
          
          # Symbol array enums should work correctly
          expect(user.role.to_s).to eq('admin')
          expect(user.hobbies.map(&:to_s)).to contain_exactly('reading', 'travel')
        end
      end

      context 'with upsert_all' do
        it 'correctly saves string values for Hash-based enum' do
          User.upsert_all([user_data], unique_by: :email)
          user = User.find_by(email: user_data[:email])
          
          # This test SHOULD pass but FAILS in Rails 8 with integer columns
          expect(user.status.to_s).to eq('inactive')
        end

        it 'correctly updates existing records' do
          # Create initial record
          User.create!(user_data.merge(status: 'active'))
          
          # Update via upsert_all
          User.upsert_all([user_data], unique_by: :email)
          user = User.find_by(email: user_data[:email])
          
          # This test SHOULD pass but FAILS - status remains 'active'
          expect(user.status.to_s).to eq('inactive')
        end
      end
    end

    describe 'numeric values in bulk operations' do
      it 'works correctly when using numeric values directly' do
        numeric_data = user_data.merge(status: 1) # 1 = inactive
        
        User.insert_all([numeric_data])
        user = User.find_by(email: user_data[:email])
        
        # This works as a workaround
        expect(user.status.to_s).to eq('inactive')
      end
    end
  end

  describe 'enumerize configuration' do
    it 'has Hash-based enum for status with integer database column' do
      status_column = User.columns.find { |c| c.name == 'status' }
      
      expect(status_column.type).to eq(:integer)
      expect(User.status.values).to eq(['active', 'inactive', 'suspended'])
      expect(User.status.find_value('inactive').value).to eq(1)
      expect(User.status.find_value('suspended').value).to eq(3)
    end

    it 'has Symbol array enum for role' do
      expect(User.role.values).to eq(['admin', 'manager', 'employee', 'intern'])
    end

    it 'has Symbol array enum for hobbies with multiple selection' do
      expect(User.hobbies.values).to eq(['reading', 'sports', 'cooking', 'gaming', 'music', 'travel'])
    end
  end
end