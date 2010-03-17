def js_libs
  [
    "public/javascripts/application.js"
  ]
end

namespace :js do
  desc "Run JSLint on application code"
  task :lint do
    jslint = File.join('lib', 'fulljslint.js')
    errors = []
    $stdout.write "Running JSLint on #{js_libs.inspect}\n"; $stdout.flush
    js_libs.each do |f|
      output = `rhino #{jslint} #{f}`
      if output =~ /No\ problems\ found/
        $stdout.write "\e[32m.\e[0m"
      else
        $stdout.write "\e[31mF\e[0m"
        errors << {:file => f, :error => output}
      end
      $stdout.flush
    end
    $stdout.write "\n"
    errors.each do |e|
      puts "------------------------------"
      puts e[:file]
      puts e[:error]+"\n"
    end
    raise "Errors found during JS Lint" unless errors.empty?
  end
end

desc 'Run jslint on application code'
task :js => 'js:lint'
