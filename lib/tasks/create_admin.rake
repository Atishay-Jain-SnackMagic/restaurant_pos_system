desc "Creating a new admin user"
task :create_admin, [ :name, :email, :password ] => :environment do |_, args|
  user = User.new(name: args[:name], email: args[:email], password: args[:password], is_admin: true)
  if user.save
    puts "Admin user '#{user.name}' created successfully with email '#{user.email}'."
  else
    puts "Error creating user: #{user.errors.full_messages}"
  end
end
