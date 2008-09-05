namespace :test do

  desc 'Measures test coverage'
  task :coverage do
    rm_f "coverage"
    rm_f "coverage.data"
    rcov = "rcov --rails -Ilib -Itest"
    system("#{rcov} test/unit/*_test.rb")
    system("#{rcov} test/functional/*_test.rb")
    system("#{rcov} test/integration/*_test.rb")
  end

end
