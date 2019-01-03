desc "Alias for docker-compose up --build"
task :start do
  system("docker-compose up --build")
end

desc "Alias for docker-compose run web rspec"
task :rspec do
  system("docker-compose run web rspec")
end

desc "Alias for rubocop with safe auto correct"
task :rubocop do
  system("rubocop --safe-auto-correct")
end
