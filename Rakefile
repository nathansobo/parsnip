require 'bundler'
Bundler::GemHelper.install_tasks

task :watch do
  require 'fssm'


  FSSM.monitor(File.expand_path('./lib/parsnip/'), '*.kpeg') do
    update do |base, relative|
      puts "Change detected..."
      system 'bundle exec kpeg --force ./lib/parsnip/parsnip.kpeg'
    end
  end
end

