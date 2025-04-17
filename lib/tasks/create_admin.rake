desc "Creating a new admin user"
task :create_admin, [ :name, :email ] => :environment do |_, args|
  print 'Enter password: '
  password = STDIN.noecho(&:gets).chomp
  puts ''
  user = User.new(name: args[:name], email: args[:email], password: password, is_admin: true)
  if user.save
    puts "Admin user '#{user.name}' created successfully with email '#{user.email}'."
  else
    puts "Error creating user: #{user.errors.full_messages}"
  end
end
